require('coffeescript/register')
require('coffee-coverage/register-istanbul')

// Setup chai
const chai = require('chai')
global.expect = chai.expect
chai.should()
chai.use(require('sinon-chai'))

// Setup sinon
global.sinon = require('sinon')
