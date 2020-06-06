import sys
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import (QApplication, QWidget, QLabel, QPushButton, QVBoxLayout, QHBoxLayout,
                             QTabWidget, QCheckBox, QRadioButton, QScrollArea, QHeaderView)

from PyQt5.QtCore import Qt
from RecipeCollection import RecipeCollection

class TaskWidget(QWidget):

    def __init__(self, task):

        super().__init__()

        # Widgets
        self.checkBox = QCheckBox()
        self.nameLabel = QLabel(task['name'])
        self.descriptionLabel = QLabel(task['description'])
        self.radioButton1 = QRadioButton()
        self.radioButton1.clicked.connect(lambda: self.radioButtonClicked(1))
        self.radioButton2 = QRadioButton()
        self.radioButton3 = QRadioButton()
        self.radioButton3.setEnabled(False)

        # Layout
        self.layout = QHBoxLayout()
        self.layout.addWidget(self.checkBox)
        self.layout.addWidget(self.nameLabel)
        self.layout.addWidget(self.descriptionLabel)
        self.layout.addWidget(self.radioButton1)
        self.layout.addWidget(self.radioButton2)
        self.layout.addWidget(self.radioButton3)
        self.setLayout(self.layout)


    def radioButtonClicked(self, n):
        print(n)



class TaskListWidget(QWidget):

   def __init__(self, taskType, taskList):

        super().__init__()

        # Scroll header
        self.header = QWidget()
        self.headerLayout = QHBoxLayout()

        if taskType == 'generic':
            self.runLabel = QLabel('Run')
            self.runLabel.setFixedSize(100, 15)
            self.headerLayout.addWidget(self.runLabel)

            self.nameLabel = QLabel('Name')
            self.nameLabel.setFixedSize(300, 15)
            self.headerLayout.addWidget(self.nameLabel)

            self.descriptionLabel = QLabel('Description')
            self.descriptionLabel.setFixedSize(500, 15)
            self.headerLayout.addWidget(self.descriptionLabel)

        elif taskType == 'installable':
            self.headerLayout.addWidget(QLabel('Name'))
            self.headerLayout.addWidget(QLabel('Description'))
            self.headerLayout.addWidget(QLabel('Package'))
            self.headerLayout.addWidget(QLabel('PPA'))
            self.headerLayout.addWidget(QLabel('Deb'))
            self.headerLayout.addWidget(QLabel('Flatpak'))
            self.headerLayout.addWidget(QLabel('AppImage'))
            self.headerLayout.addWidget(QLabel('Snap'))

        else:
            raise ValueError(f"TaskListWidget: unknown taskType {taskType}")

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
        for i in range(20):
            self.tasks[str(i)] = TaskWidget({'name': 'prueba', 'description': 'descripcion'})
            self.scrollArea.layout.addWidget(self.tasks[str(i)])

        # Set scroll area widget (must be the last order)
        self.scrollArea.setWidget(self.scrollAreaContent)

        # Layout
        self.layout = QVBoxLayout()
        self.layout.addWidget(self.header)
        self.layout.addWidget(self.scrollArea)
        self.setLayout(self.layout)



class MainWindow(QWidget):

    def __init__(self, recipes):

        super().__init__()

        # Window size and title
        self.setWindowTitle('Alfred')
        # self.resize(750, 700)
        self.setMinimumWidth(700)

        # Icon
        self.setWindowIcon(QIcon('/home/david/pCloudDrive/Design/Vectorial/alfred/256B.png'))

        # Task List Widgets
        self.taskListWidgets = {}
        categories = set([recipes[recipe]['category'] for recipe in recipes])

        for category in categories:
            self.taskListWidgets[category] = TaskListWidget(category, [])

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

