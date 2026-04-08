# ipodnano7sport : How to use ?
Script and dashboard visualizer : for your iPod Nano 7th Gen Run Workout data.

Step 1 - download the 3 files : run.bat + index.html + parse_runs.ps1
Step 2 - copy them in the iPod Nano 7th Gen root directory
Step 3 - execute the "run.bat" file

# ipodnano7sport : What it does ?
- it compiles your run data (not the pedometer of walk data, but the run wourkouts) to a new file (created by the .ps1 file) called : data.js
- the "index.html" opens by itself
- the cmd windows closes by itself
- you can visualize your run datasets + a summary

# ipodnano7sport : can you personalize the aestetic ?
- yes you can personalize the colorset, the size of tiles, the font family : by modifying this part (at the begining of the index.html) :
  :root {
  --bg: #fadc96;
  --neon: #000000;
  --neon2: #000000;
  --neon3: #000000;
  --neon4: #000000;
  --text: #000000;
  --card-w: 250px;
  --card-h: 280px;
  --zoom-stats: 1.3;
  --font-main: "Arial Narrow", Arial, sans-serif;}
- you just need to open index.html in any random text editor
