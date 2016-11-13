import matplotlib.pyplot as plt; plt.rcdefaults()
import numpy as np
import matplotlib.pyplot as plt
 
objects = []
values = [] 

for letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
	objects.append(letter)
	values.append(7)

y_pos = np.arange(len(objects))

 
plt.bar(y_pos, values, align='center', alpha=0.5)
plt.xticks(y_pos, objects)
plt.ylabel('Usage')
plt.title('Programming language usage')
 
plt.show()