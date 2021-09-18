var exec = require('child_process').exec;
var fs = require('fs')
var path = require('path')
var pkg = require('./package.json')

console.log("+ Building typescript files...")
exec("npx tsc --build")
console.log("✔ Done!")
console.log("\n+ Copying files to dist dir...")
fs.copyFileSync('package.json', '.' + path.sep + 'dist' + path.sep + 'package.json')
console.log("✔ package.json copied!")
fs.copyFileSync('.env', '.' + path.sep + 'dist' + path.sep + '.env')
console.log("✔ .env copied!")
console.log(`\n😀 Successfully builded ${pkg.name} project!`)
