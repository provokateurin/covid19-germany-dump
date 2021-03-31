set datafile separator ","
set title "Covid 19 daily cases averaged over the last week for Germany"
set terminal png size 1024,512
set output "weekly.png"
set xdata time
set timefmt '%Y-%m-%d'
set format x '%m/%y'
plot 'weekly.csv' using 1:2 title "daily cases averaged over the last week" with lines linecolor rgb '#0060ad' linewidth 1
