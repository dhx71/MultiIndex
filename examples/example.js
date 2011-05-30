var MultiIndex = require('../lib/MultiIndex');
var util = require('util');

var store = new MultiIndex;

var obj1 = {
    sessionid:'1'
  , connectionid: 1
  , username: 'jo'
  , group: 'testers'
  , city: 'montreal'
};
var obj2 = {
    sessionid:'2'
  , connectionid: 2
  , username: 'hellen'
  , group: 'writers'
  , city: 'montreal'
};

// add obj1 into store
obj1.id = store.set(obj1);

// index obj1 by username, group, connectionid and city
store.index(obj1.id, {
    username    : obj1.username
  , group       : obj1.group
  , connectionid: obj1.connectionid
  , city        : obj1.city
    });

// add obj2 into store
obj2.id = store.set(obj2);

// index obj2 by username, group, connectionid and city
store.index(obj2.id, {
    username    : obj2.username
  , group       : obj2.group
  , connectionid: obj2.connectionid
  , city        : obj2.city
  });

console.log('get username:jo: '+util.inspect(store.getOne({username:'jo'})));

function sendMsg(indexes, msg) {
    store.forEach(indexes, function (obj) {
        console.log('sending a message to user:'+obj.username);
        // ... send message
    });
}

// send a message to everyones in montreal
sendMsg({city:'montreal'}, 'hello');

function onDisconnect(connectionid) {
    console.log(store.getOne({connectionid:connectionid}).username+' disconnected');
    store.remove({connectionid: connectionid});
}

// user with connectionid 2 just disconnected
onDisconnect(2);

// send a message to everyones in montreal
sendMsg({city:'montreal'}, 'salut');

