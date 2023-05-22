# !/usr/bin/python3
import numpy as np
import matplotlib.pyplot as plt

# parameters to modify
filename='/home/ubuntu/CWM-ProgNets/assignment2/ping51.txt'
label='label'
xlabel = 'xlabel'
ylabel = 'ylabel'
title='Simple plot'
fig_name='test51.png'


t = np.loadtxt(filename, delimiter=" ", dtype="float")
print(t[3])
plt.plot(t[:,0], t[:,1], label=label)  # Plot some data on the (implicit) axes.
plt.xlabel(xlabel)
plt.ylabel(ylabel)
plt.title(title)
plt.legend()
plt.savefig(fig_name)
plt.show()
