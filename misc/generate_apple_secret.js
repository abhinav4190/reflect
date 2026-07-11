const fs = require('fs');
const jwt = require('jsonwebtoken');

const privateKey = fs.readFileSync('AuthKey_6FM9VZ293R.p8').toString();

const teamId = 'K6LM29242X';
const clientId = 'com.abhinav.reflect.signin'; 
const keyId = '6FM9VZ293R';

const token = jwt.sign({}, privateKey, {
  algorithm: 'ES256',
  expiresIn: '180d',
  audience: 'https://appleid.apple.com',
  issuer: teamId,
  subject: clientId,
  keyid: keyId,
});

console.log(token);