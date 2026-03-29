
#include <stdio.h>
#include <string.h>

#define MAX 100

struct Task {
    char name[50];
    char subject[50];
    int priority;
    int deadline;
    int completed;
};

struct Task tasks[MAX];
int taskCount = 0;

// Function to sort tasks based on priority and deadline
void sortTasks() {
    for (int i = 0; i < taskCount - 1; i++) {
        for (int j = i + 1; j < taskCount; j++) {
            if (tasks[i].priority > tasks[j].priority ||
               (tasks[i].priority == tasks[j].priority &&
                tasks[i].deadline > tasks[j].deadline)) {

                struct Task temp = tasks[i];
                tasks[i] = tasks[j];
                tasks[j] = temp;
            }
        }
    }
}

int main() {
    int choice;

    do {
        printf("\n--- SMART STUDY PLANNER ---\n");
        printf("1. Add Task\n2. View Tasks\n3. Highest Priority Task\n");
        printf("4. Mark Completed\n5. Generate Daily Plan\n6. Exit\n");
        printf("Enter choice: ");
        scanf("%d", &choice);

        if (choice == 1) {
            struct Task t;

            printf("Enter task name: ");
            scanf("%s", t.name);

            printf("Enter subject: ");
            scanf("%s", t.subject);

            printf("Enter priority (1-High, 2-Medium, 3-Low): ");
            scanf("%d", &t.priority);

            printf("Enter deadline (day number): ");
            scanf("%d", &t.deadline);

            t.completed = 0;

            tasks[taskCount++] = t;
        }

        else if (choice == 2) {
            printf("\nAll Tasks:\n");
            for (int i = 0; i < taskCount; i++) {
                printf("%s | %s | Priority: %d | Deadline: %d | %s\n",
                       tasks[i].name,
                       tasks[i].subject,
                       tasks[i].priority,
                       tasks[i].deadline,
                       tasks[i].completed ? "Done" : "Pending");
            }
        }

        else if (choice == 3) {
            if (taskCount == 0) {
                printf("No tasks available!\n");
            } else {
                sortTasks();
                printf("\nTop Priority Task: %s\n", tasks[0].name);
            }
        }

        else if (choice == 4) {
            char name[50];
            printf("Enter task name to mark complete: ");
            scanf("%s", name);

            for (int i = 0; i < taskCount; i++) {
                if (strcmp(tasks[i].name, name) == 0) {
                    tasks[i].completed = 1;
                    printf("Task marked as completed!\n");
                }
            }
        }

        else if (choice == 5) {
            sortTasks();
            printf("\nToday's Schedule:\n");

            for (int i = 0; i < taskCount; i++) {
                if (!tasks[i].completed) {
                    printf("%s -> %s\n", tasks[i].name, tasks[i].subject);
                }
            }
        }

    } while (choice != 6);

    return 0;
}