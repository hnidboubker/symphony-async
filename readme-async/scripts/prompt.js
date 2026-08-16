// prompt.js — Simple interactive prompt for Node.js

import { createInterface } from 'readline';
import { stdin, stdout } from 'process';

export function prompt(question) {
  const rl = createInterface({ input: stdin, output: stdout });
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer);
    });
  });
}