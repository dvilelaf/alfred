import sys
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import (QApplication, QWidget, QLabel, QPushButton, QVBoxLayout, QHBoxLayout,
                             QTabWidget, QCheckBox, QRadioButton, QScrollArea, QHeaderView)

from PyQt5.QtCore import Qt
from RecipeCollection import RecipeCollection


genericLabelTexts = ['Task', 'Description', 'Run']
genericLabelWidths = [150, 500, 30]

nonGenericLabelTexts = ['Task', 'Description', 'Repo', 'PPA', 'Deb', 'Flatpak', 'AppImage', 'Snap']
nonGenericLabelWidths = [150, 500, 100, 70, 70, 70, 70, 70]

packageTypes = ['repo', 'ppa', 'deb', 'flatpak', 'appimage', 'snap']


class TaskWidget(QWidget):

    def __init__(self, taskName, task):

        super().__init__()
        # Widgets
        self.widgets = []
        self.widgets.append(QLabel(taskName))
        self.widgets.append(QLabel(task['description']))

        if task['category'] == 'generic':
            self.checkBox = QCheckBox()
            self.widgets.append(QCheckBox())

            # for i in range(len(self.widgets)):
                # self.widgets[i].setFixedSize(genericLabelWidths[i], 15)
                # self.widgets[i].setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)

        else:
            availablePackageTypes = [recipe['type'] for recipe in task['recipes']]
            for packageType in packageTypes:
                if packageType in availablePackageTypes:
                    self.widgets.append(QRadioButton())
                else:
                    self.widgets.append(QLabel('-'))

            for i in range(len(self.widgets)):
                self.widgets[i].setFixedSize(nonGenericLabelWidths[i], 15)
                # self.widgets[i].setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)

        # self.radioButton1.clicked.connect(lambda: self.radioButtonClicked(1))
        # self.radioButton3.setEnabled(False)

        # Layout
        self.layout = QHBoxLayout()
        for widget in self.widgets:
            self.layout.addWidget(widget)
        self.setLayout(self.layout)


    def radioButtonClicked(self, n):
        print(n)



class TaskListWidget(QWidget):

   def __init__(self, taskType, taskList):

        super().__init__()

        # Scroll header
        self.header = QWidget()
        self.headerLayout = QHBoxLayout()

        labelTexts = None
        labelWidths = None

        if taskType == 'generic':
            labelTexts = genericLabelTexts
            labelWidths = genericLabelWidths
        else:
            labelTexts = nonGenericLabelTexts
            labelWidths = nonGenericLabelWidths

        self.labels = []

        for i in range(len(labelTexts)):
            self.labels.append(QLabel(labelTexts[i]))
            self.labels[-1].setFixedSize(labelWidths[i], 15)
            # self.labels[-1].setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
            self.headerLayout.addWidget(self.labels[-1])

        self.header.setLayout(self.headerLayout)

        # Scroll area
        self.scrollAreaContent = QWidget()
        self.scrollArea = QScrollArea()
        self.scrollArea.layout = QVBoxLayout(self.scrollAreaContent)
        self.scrollArea.setMinimumWidth(self.scrollAreaContent.sizeHint().width())
        self.scrollArea.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.scrollArea.setStyleSheet("""QWidget{ background-color: white }
                                         QScrollBar{ background-color: none }""")
        # Add tasks to scroll area
        self.tasks = {}
        for taskName in taskList:
            self.tasks[taskName] = TaskWidget(taskName, taskList[taskName])
            self.scrollArea.layout.addWidget(self.tasks[taskName])

        # Set scroll area widget (must be the last order)
        self.scrollArea.setWidget(self.scrollAreaContent)

        # Layout
        self.layout = QVBoxLayout()
        self.layout.addWidget(self.header)
        self.layout.addWidget(self.scrollArea)
        self.setLayout(self.layout)



class MainWindow(QWidget):

    def __init__(self, tasks):

        super().__init__()

        # Window size and title
        self.setWindowTitle('Alfred')
        # self.resize(750, 700)
        # self.setMinimumWidth(700)
        self.setMinimumHeight(500)

        # Icon
        self.setWindowIcon(QIcon('/home/david/pCloudDrive/Design/Vectorial/alfred/256B.png'))

        # Task List Widgets
        self.taskListWidgets = {}
        categories = sorted(set([tasks[task]['category'] for task in tasks]))

        for category in categories:
            categoryTasks = {task: tasks[task] for task in tasks if tasks[task]['category'] == category}
            self.taskListWidgets[category] = TaskListWidget(category, categoryTasks)

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

