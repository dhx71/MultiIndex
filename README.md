## Synopsis ##

MultiIndex is a [node.js](http://nodejs.org/) module allowing you to index JavaScript objects. 
You can dynamically add any numbers of indexes to your objects. 

## How to use MultiIndex ##

A Multi-indexed objects store is created like this:

``` js
    
    var MultiIndex = require('MultiIndex');
    var util = require('util');

    var store = new MultiIndex;
```

You can add an object into the store using the `add(obj, [indexes])` function.

``` js

    var obj1 = {
        sessionid:'1'
      , connectionid: 1
      , username: 'jo'
      , group: 'testers'
      , city: 'montreal'
    };
    
    // add obj1 into store but don't index it yet
    obj1.id = store.add(obj1);
```

Object can be indexed at insersion time or later. 
You can index an object at any time with the `index(id, indexes)` function.

``` js

    // index obj1 by username, group, connectionid and city
    store.index(obj1.id, {
        username    : obj1.username
      , group       : obj1.group
      , connectionid: obj1.connectionid
      , city        : obj1.city
        });

    var obj2 = {
        sessionid:'2'
      , connectionid: 2
      , username: 'hellen'
      , group: 'tech writer'
      , city: 'montreal'
    };
    
    // add obj2 into store and index it
    obj2.id = store.add(obj2, {
        username    : obj2.username
      , group       : obj2.group
      , connectionid: obj2.connectionid
      , city        : obj2.city
    });
```

There are two getter functions. One is to get one single object and the other is to 
get all objects correspoding to the provided indexes.

    var obj = getOne(indexes)

    var arrObjs = get(indexes)

``` js

    var obj = store.getOne({username:'jo'});
    if (obj) {
        //...
    }

```

Iterates through store for objects indexed by indexes.

``` js

    store.forEach({city:'montreal'}, function (obj) {
        console.log('sending a message to user:'+obj.username);
        // ...
    });

```

Object can be removed with function `remove(indexes)`

``` js

    store.remove({connectionid: connectionid});

```

## API ##

see [MultiIndex.md](doc/MultiIndex.md) under doc/

## TODOs ##

- publish with npm
- add function to remove some indexes

