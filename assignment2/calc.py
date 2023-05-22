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
m = max(t)
s = min(t)
mean = sum(t)/len(t)
print(m,s,mean)
