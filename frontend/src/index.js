const fs = require('fs');
const path = require('path');
const serve = require('./serve');
const boot = require('./boot');
const call = require('./call');
const compile = require('./compile');
const deploy = require('./deploy');

const SOURCE = path.join(__dirname, '../..', 'contracts', 'Main.sol');

async function main() {
  const { vm, pk } = await boot();

  async function handler() {
    const { abi, bytecode } = compile(SOURCE);
    const address = await deploy(vm, pk, bytecode);
    const stringSVG = await call(vm, address, abi, 'getSVG');
    const base64SVG = await call(vm, address, abi, 'svgToBase64');
    
    return {
      stringSVG, base64SVG
    };
  }

  const { notify } = await serve(handler);

  fs.watch(path.dirname(SOURCE), notify);
  console.log('Watching', path.dirname(SOURCE));
  console.log('Serving  http://localhost:9901/');
}

main();
