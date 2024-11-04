import numpy as np
import matplotlib.pyplot as plt

a = 1073000191
b = 32190005730
c = 30
# b = 300
# a = 660_000_000
# c = 30


x_value = 300
y_target = 6e8

# Define the function
def y_function(x):
    return a - b / (c + x)

current_y = y_function(x_value)
difference = y_target - current_y
a_new = a + difference
print(a_new)

# Generate x values
x_values = np.linspace(0, 350, 400)  # 400 points between 0 and 100
y_values = y_function(x_values)

print("|\tGAS Amount\t|\tToken Amount\t\t|")
print("|"+"-"*55+"|")
for i in range(1,10):
    print(f"|\t{i}\t\t|\t{y_function(i)}\t|")
    
print(f"|\t{50}\t\t|\t{y_function(50)}\t|")
print(f"|\t{100}\t\t|\t{y_function(100)}\t|")
    
for i in range(295, 301):
    print(f"|\t{i}\t\t|\t{y_function(i)}\t|")

# Plot the function
plt.figure(figsize=(10, 6))
plt.plot(x_values, y_values, label=f"y = {a} - {b} / ({c} + x)")
plt.xlabel('x')
plt.ylabel('y')
plt.title(f'Plot of the function  = {a} - {b} / ({c} + x)')
plt.legend()
plt.grid(True)
plt.show()
