set datafile separator ","
set title "Covid 19 absolute cases for Germany"
set terminal png size 1024,512
set output "absolute.png"
set xdata time
set timefmt '%Y-%m-%d'
set format x '%m/%y'
plot 'absolute.csv' using 1:2 title "absolute cases" with lines linecolor rgb '#0060ad' linewidth 1
