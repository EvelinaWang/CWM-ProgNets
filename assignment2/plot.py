# !/usr/bin/python3
import numpy as np
import matplotlib.pyplot as plt

# parameters to modify
time = np.linspace(0 , 10.0213, 100)
if time <1:
    b = 955
elif time <3:
    b=940
elif time<4:
    b=946
elif time<5:
    b=938
elif time<6:
    b=944
elif b<8:
    b=942
else:
    b=941

label='Pi server'
xlabel = 'time'
ylabel = 'Bandwidth'
title='Bandwith plot'
fig_name='iperf2.png'


t = np.loadtxt(filename, delimiter=" ", dtype="float")

plt.plot(time, b, label=label)  # Plot some data on the (implicit) axes.
plt.xlabel(xlabel)
plt.ylabel(ylabel)
plt.title(title)
plt.legend()
plt.savefig(fig_name)
plt.show()
