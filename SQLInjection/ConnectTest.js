var Connection = require('tedious').Connection;
var Request = require('tedious').Request;
var TYPES = require('tedious').TYPES;

// Create connection to database
var config = {
  server: 'TESTBED\\SQL2017',
  authentication: {
      type: 'default',
      options: {
          userName: 'Grant', // update me
          password: '1234' // update me
      }
  },
  options: {
      database: 'AdventureWorks2017'
  }
}
var connection = new Connection(config);


// Attempt to connect and execute queries if connection goes through
connection.on('connect', function(err) {
    if (err) {
      console.log(err);
    } else {
      console.log('Connected');
    }
  });