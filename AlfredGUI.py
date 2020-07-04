import sys
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import (QApplication, QWidget, QLabel, QPushButton, QVBoxLayout, QHBoxLayout,
                             QTabWidget, QCheckBox, QRadioButton, QScrollArea, QGridLayout,
                             QButtonGroup, QMessageBox, QProgressBar)

from PyQt5.QtCore import Qt, pyqtSignal
from RecipeCollection import RecipeCollection


packageTypes = {'repo': 0, 'ppa': 1, 'deb': 2, 'flatpak': 3, 'appimage': 4, 'snap': 5}

genericLabelTexts = ['Task', 'Description', 'Run']
genericRowCellWidths = [1.5, 5, 0.7]
genericLabelAlignments = [Qt.AlignLeft, Qt.AlignLeft, Qt.AlignCenter]

nonGenericLabelTexts = ['Name', 'Description', 'Repo', 'PPA', 'Deb', 'Flatpak', 'AppImage', 'Snap']
nonGenericRowCellWidths = [1.5, 5, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7]
nonGenericLabelAlignments = [Qt.AlignLeft, Qt.AlignLeft, Qt.AlignCenter, Qt.AlignCenter, Qt.AlignCenter, Qt.AlignCenter, Qt.AlignCenter, Qt.AlignCenter]



class ProgressBar(QWidget):

    nextWindowSignal = pyqtSignal()

    def __init__(self):
        super().__init__()

        self.setWindowTitle('Alfred')
        # self.setWindowFlag(Qt.WindowCloseButtonHint, False)
        # self.setWindowFlag(Qt.WindowMaximizeButtonHint, False)
        # self.setWindowFlag(Qt.WindowMinimizeButtonHint, False)

        self.progress = QProgressBar(self)
        self.progress.setGeometry(10, 10, 500, 30)
        self.progress.setValue(50)
        self.progress.setAlignment(Qt.AlignCenter)
        self.progress.setFormat('Processing tasks...')


    def updateText(self, text):
        self.progress.setFormat(text)


    def nextWindow(self):
        self.nextWindowSignal.emit()



class WarningWindow(QMessageBox):

    nextWindowSignal = pyqtSignal()

    def __init__(self):
        super().__init__()

        self.setWindowTitle('Alfred')
        self.setIcon(QMessageBox.Warning)
        self.setText("Alfred is about to install the selected applications and you won't be able to cancel this operation once started.\n\nAre you sure you want to continue?")
        self.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)
        self.buttonClicked.connect(self.nextWindow)


    def nextWindow(self, button):
        print(button)
        self.nextWindowSignal.emit()



class TaskListWidget(QWidget):

    def __init__(self, columnHeaders, columnSpans, columnHAlignments, minimumColumnWidth):
        super().__init__()

        self.columnHAlignments = columnHAlignments
        self.rows = {}
        self.radioGroups = {}

        # Header
        self.header = QWidget()
        self.headerLayout = QHBoxLayout()
        self.header.setLayout(self.headerLayout)

        self.headerLabels = []

        for i in range(len(columnHeaders)):

            self.headerLabels.append(QLabel(columnHeaders[i]))
            self.headerLabels[-1].setAlignment(columnHAlignments[i])
            self.headerLabels[-1].setMinimumWidth(columnSpans[i] * minimumColumnWidth)

            self.headerLayout.addWidget(self.headerLabels[-1])
            self.headerLayout.setStretch(i, columnSpans[i])

        # Grid
        self.grid = QWidget()
        self.gridLayout = QGridLayout()

        for i in range(len(columnSpans)):
            self.gridLayout.setColumnStretch(i, columnSpans[i])
            self.gridLayout.setColumnMinimumWidth(i, columnSpans[i] * minimumColumnWidth)

        self.grid.setLayout(self.gridLayout)

        # Scroll area
        self.scrollArea = QScrollArea()
        self.scrollArea.setWidget(self.grid)
        self.scrollArea.setWidgetResizable(True)
        self.scrollArea.setStyleSheet("""QWidget{ background-color: white }
                                         QScrollBar{ background-color: none }""")

        # Compute the correct minimum width
        width = (self.grid.sizeHint().width() +
                 self.scrollArea.verticalScrollBar().sizeHint().width() +
                 self.scrollArea.frameWidth() * 2)

        self.scrollArea.setMinimumWidth(width)

        # Layout
        self.layout = QVBoxLayout()
        self.layout.addWidget(self.header)
        self.layout.addWidget(self.scrollArea)
        self.setLayout(self.layout)


    def addRow(self, name, elements):
        self.rows[name] = elements
        self.radioGroups[name] = QButtonGroup()
        self.radioGroups[name].setExclusive(False)
        self.radioGroups[name].buttonClicked.connect(self.check_buttons)

        for column in range(len(self.rows[name])):
            self.gridLayout.addWidget(self.rows[name][column],
                                      len(self.rows) - 1, column,
                                      Qt.AlignVCenter | self.columnHAlignments[column])

            if isinstance(self.rows[name][column], QRadioButton):
                self.radioGroups[name].addButton(self.rows[name][column])
                self.radioGroups[name].setId(self.rows[name][column], list(packageTypes.values())[column - 2])


    def check_buttons(self, radioButton):
        # Search for this button's group
        for radioGroup in list(self.radioGroups.values()):
            if radioButton in radioGroup.buttons():
                # Uncheck every other button in this group
                for button in radioGroup.buttons():
                    if button is not radioButton:
                        button.setChecked(False)
                break



class SelectionWindow(QWidget):

    nextWindowSignal = pyqtSignal()

    def __init__(self, tasks):
        super().__init__()

        # Window title
        self.setWindowTitle('Alfred')

        # Icon
        self.setWindowIcon(QIcon('/home/david/pCloudDrive/Design/Vectorial/alfred/256B.png'))

        # Task List Widgets
        self.taskListWidgets = {}
        categories = sorted(set([tasks[task]['category'] for task in tasks])) # Get all categories

        for category in categories:
            categoryTasks = {task: tasks[task] for task in tasks if tasks[task]['category'] == category} # Get all tasks in a category

            taskListWidget = None
            if category == 'generic':
                taskListWidget = TaskListWidget(genericLabelTexts, genericRowCellWidths, genericLabelAlignments, 100)
                for task in categoryTasks:
                    taskListWidget.addRow(task,
                                          [QLabel(task),
                                           QLabel(categoryTasks[task]['description']),
                                           QCheckBox()])
            else:
                taskListWidget = TaskListWidget(nonGenericLabelTexts, nonGenericRowCellWidths, nonGenericLabelAlignments, 100)
                for task in categoryTasks:
                    availablePackageTypes = [recipe['type'] for recipe in categoryTasks[task]['recipes']]
                    packageRadioButtons = []
                    for packageType in packageTypes:
                        if packageType in availablePackageTypes:
                            packageRadioButtons.append(QRadioButton())
                        else:
                            packageRadioButtons.append(QLabel('-'))

                    taskListWidget.addRow(task,
                                          [QLabel(task),
                                           QLabel(categoryTasks[task]['description'])] + packageRadioButtons)

            taskListWidget.gridLayout.setRowStretch (len(taskListWidget.rows), 1) # Do not stretch rows vertically
            self.taskListWidgets[category] = taskListWidget

        # Tabs widget
        self.tabsWidget = QTabWidget()
        self.tabsWidget.tabBar().setExpanding(True)
        for category in categories:
            self.tabsWidget.addTab(self.taskListWidgets[category], category.capitalize())

        # Run button
        self.runButton = QPushButton("Run")
        self.runButton.setFixedSize(150, 30)
        self.runButton.clicked.connect(self.nextWindow)

        # Layout
        self.layout = QVBoxLayout()
        self.layout.addWidget(self.tabsWidget)
        self.layout.addWidget(self.runButton, 0, Qt.AlignHCenter)
        self.setLayout(self.layout)


    def getSelectedRecipes(self):
        selectedRecipes = []

        # Non generic tasks
        for taskList in self.taskListWidgets.values():
            for taskName in taskList.radioGroups:
                checkedId = taskList.radioGroups[taskName].checkedId()
                if checkedId != -1:
                    selectedRecipes.append((taskName, list(packageTypes.keys())[checkedId]))

        # Generic tasks
        for genericTaskName, widgets in self.taskListWidgets['generic'].rows.items():
            for widget in widgets:
                if isinstance(widget, QCheckBox) and widget.isChecked():
                    selectedRecipes.append(genericTaskName)

        return selectedRecipes


    def nextWindow(self):
        selectedRecipes = self.getSelectedRecipes()
        self.nextWindowSignal.emit()



class Controller:

    def __init__(self):
        pass

    def showSelectionWindow(self, recipes):
        self.selectionWindow = SelectionWindow(recipes)
        self.selectionWindow.nextWindowSignal.connect(self.showWarningWindow)
        self.selectionWindow.show()


    def showWarningWindow(self):
        self.warningWindow = WarningWindow()
        self.warningWindow.nextWindowSignal.connect(self.showProgressBar)
        self.warningWindow.show()


    def showProgressBar(self):
        self.selectionWindow.hide()
        self.warningWindow.hide()
        self.progressBar = ProgressBar()
        # self.progressBar.nextWindowSignal.connect(self.resultWindow)
        self.progressBar.show()



if __name__ == '__main__':

    recipes = RecipeCollection('/home/david/Nextcloud/Code/Projects/alfred/recipes.json',
                               '/home/david/Nextcloud/Code/Projects/alfred/recipeSchema.json')
    if recipes.loaded:
        app = QApplication(sys.argv)
        controller = Controller()
        controller.showSelectionWindow(recipes)
        app.exec_()
    else:
        sys.exit(recipes.error)
