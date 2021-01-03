set datafile separator ","
set title "Covid 19 daily cases for Germany"
set terminal png size 1024,512
set output "daily.png"
set xdata time
set timefmt '%Y-%m-%d'
set format x '%m/%y'
plot 'daily.csv' using 1:2 title "daily cases" with lines linecolor rgb '#0060ad' linewidth 1
