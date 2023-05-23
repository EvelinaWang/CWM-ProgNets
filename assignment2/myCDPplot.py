# !/usr/bin/python3
import numpy as np
import matplotlib.pyplot as plt

# parameters to modify
filename='/Users/evelina/Desktop/ping53.txt'
label='interval=0.001'
xlabel = 'time'
ylabel = 'accumulative possibility'
title='CDP plot'
fig_name='test53.png'


t = np.loadtxt(filename, delimiter=" ", dtype="float")
t_sorted = np.sort(t)
p = 1. * np.arange(len(t)) / (len(t) - 1)
print(len(t_sorted), len(p))
plt.plot(t_sorted, p, label=label)  # Plot some data on the (implicit) axes.
plt.xlabel(xlabel)
plt.ylabel(ylabel)
plt.title(title)
plt.legend()
plt.savefig(fig_name)
plt.show()
