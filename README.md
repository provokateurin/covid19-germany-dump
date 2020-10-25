# covid19-germany-dump
Update the data:
```bash
git submodule init
git submodule update --remote --merge
```
Run the dump program:
```bash
pub get
dart dump.dart
```
Look at the results in `dump.csv`.

Data from [COVID-19 Data Repository by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University](https://github.com/CSSEGISandData/COVID-19)