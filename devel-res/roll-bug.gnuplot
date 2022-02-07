set datafile separator ','
set key autotitle columnhead
set ylabel "Values"
set xlabel "Time"
set term png size 7000,700
set output "combined.png"
plot for [col = 1:7] "p210n.csv" using 1:col with lines

set term png size 3000,600

set output "roll_beta.png"
plot "p210n.csv" using 1:2 with lines

set output "roll_damp.png"
plot "p210n.csv" using 1:3 with lines

set output "roll_yaw.png"
plot "p210n.csv" using 1:4 with lines

set output "yaw_beta.png"
plot "p210n.csv" using 1:5 with lines

set output "yaw_damp.png"
plot "p210n.csv" using 1:6 with lines

set output "yaw_rollrate.png"
plot "p210n.csv" using 1:7 with lines

