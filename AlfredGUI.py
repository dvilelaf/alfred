import sys
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import (QApplication, QWidget, QLabel, QPushButton, QVBoxLayout, QHBoxLayout,
                             QTabWidget, QCheckBox, QRadioButton, QScrollArea, QGridLayout)

from PyQt5.QtCore import Qt
from RecipeCollection import RecipeCollection

packageTypes = ['repo', 'ppa', 'deb', 'flatpak', 'appimage', 'snap']

genericLabelTexts = ['Task', 'Description', 'Run']
genericRowCellWidths = [1.5, 4, 1]
genericLabelAlignments = [Qt.AlignLeft, Qt.AlignLeft, Qt.AlignCenter]

nonGenericLabelTexts = ['Name', 'Description', 'Repo', 'PPA', 'Deb', 'Flatpak', 'AppImage', 'Snap']
nonGenericRowCellWidths = [1.5, 4, 1, 1, 1, 1, 1, 1]
nonGenericLabelAlignments = [Qt.AlignLeft, Qt.AlignLeft, Qt.AlignCenter, Qt.AlignCenter, Qt.AlignCenter, Qt.AlignCenter, Qt.AlignCenter, Qt.AlignCenter]


class TaskListWidget(QWidget):

    def __init__(self, columnHeaders, columnSpans, columnHAlignments, minimumColumnWidth):

        super().__init__()

        self.columnHAlignments = columnHAlignments
        self.nRows = 0

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


    def addRow(self, elements):
        for column in range(len(elements)):
            self.gridLayout.addWidget(elements[column], self.nRows, column, Qt.AlignVCenter | self.columnHAlignments[column])
        self.nRows += 1

        # self.radioButton1.clicked.connect(lambda: self.radioButtonClicked(1))
        # self.radioButton3.setEnabled(False)

    # def radioButtonClicked(self, n):
    #     print(n)


class MainWindow(QWidget):

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
                    taskListWidget.addRow([QLabel(task),
                                           QLabel(categoryTasks[task]['description']),
                                           QCheckBox()])
            else:
                taskListWidget = TaskListWidget(nonGenericLabelTexts, nonGenericRowCellWidths, nonGenericLabelAlignments, 100)
                for task in categoryTasks:
                    availablePackageTypes = [recipe['type'] for recipe in categoryTasks[task]['recipes']]
                    packageSelectors = []
                    for packageType in packageTypes:
                        if packageType in availablePackageTypes:
                            packageSelectors.append(QRadioButton())
                        else:
                            packageSelectors.append(QLabel('-'))

                    taskListWidget.addRow([QLabel(task),
                                           QLabel(categoryTasks[task]['description'])] + packageSelectors)

            self.taskListWidgets[category] = taskListWidget

        # Tabs widget
        self.tabsWidget = QTabWidget()
        self.tabsWidget.tabBar().setExpanding(True)
        for category in categories:
            self.tabsWidget.addTab(self.taskListWidgets[category], category.capitalize())

        # Run button
        self.runButton = QPushButton("Run")
        self.runButton.setFixedSize(150, 30)

        # Layout
        self.layout = QVBoxLayout()
        self.layout.addWidget(self.tabsWidget)
        self.layout.addWidget(self.runButton, 0, Qt.AlignHCenter)
        self.setLayout(self.layout)



if __name__ == '__main__':

    recipes = RecipeCollection('/home/david/pCloudDrive/Code/Projects/alfred/recipes.json',
                               '/home/david/pCloudDrive/Code/Projects/alfred/recipeSchema.json')
    if recipes.loaded:
        app = QApplication(sys.argv)
        window = MainWindow(recipes)
        window.show()
        app.exec_()

    else:
        sys.exit(recipes.error)

