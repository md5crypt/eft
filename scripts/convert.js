/*jshint asi:true, esnext:true */
const fs = require('fs')
const data = fs.readFileSync('functions.csv','utf8').split('\n').map(x=>x.split('\t'))
const header = data.shift()
const matrix = Array.from(Array(header.length)).map(_=>[])
data.forEach(row=>row.forEach((cell,i)=>matrix[i].push(...cell.split(',').map(x=>x.trim()))))
const o = {metadata:header,data:matrix}
fs.writeFileSync('build/functions.js','var functions = '+JSON.stringify(o)+';')
console.log('done.')
