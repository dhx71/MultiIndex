MultiIndex = require '../src/MultiIndex'
assert = require 'assert'

db = new MultiIndex

obj1 = 
    k: 1
obj2 = 
    k: 2
obj3 = 
    k: 3
obj4 = 
    k: 4
    
module.exports = 
    'set obj 1': () ->
        obj1.id = db.add obj1
        assert.isDefined obj1.id
        return
        
    'index obj1': () ->
        db.index obj1.id, 
            username: 'Agent1'
            group: 'GroupA'
            DNs: ['1001','2001']
            Switch: 'SwitchA'
        assert.isDefined db.getOne obj1.id
        return
        
    'set obj 2': () ->
        obj2.id = db.add obj2
        assert.isDefined obj2.id
        return
    
    'index obj2': () ->
        db.index obj2.id, 
            username: 'Agent2'
            group: 'GroupA'
            DNs: ['1002','2002']
            Switch: 'SwitchA'
        assert.isDefined db.getOne obj2.id

    'set obj 3': () ->
        obj3.id = db.add obj3
        assert.isDefined obj3.id
        return
    
    'index obj3': () ->
        db.index obj3.id, 
            username: 'Agent3'
            group: 'GroupB'
            DNs: ['1003','2003']
            Switch: 'SwitchA'
        assert.isDefined db.getOne obj3.id
        
    'get username:"Agent1"': () ->
        assert.eql db.get(username:"Agent1")[0].id, obj1.id

    'get username:"Agent2"': () ->
        assert.eql db.get(username:"Agent2")[0].id, obj2.id

    'get username:"Agent3"': () ->
        assert.eql db.get(username:"Agent3")[0].id, obj3.id

    'get group:"GroupA"': () ->
        result = db.get group:"GroupA"
        assert.length result, 2
        assert.includes result, obj1
        assert.includes result, obj2

    'get group:"GroupB"': () ->
        result = db.get group:"GroupB"
        assert.length result, 1
        assert.includes result, obj3

    'get DNs:"1002"': () ->
        result = db.get DNs:"1002"
        assert.length result, 1
        assert.includes result, obj2

    'getOne DNs:"2001"': () ->
        result = db.getOne DNs:"2001"
        assert.eql result, obj1

    'getOne unknown:"dont exist"': () ->
        result = db.getOne unknown:"dont exist"
        assert.isNull result

    'get unknown:"dont exist"': () ->
        result = db.get unknown:"dont exist"
        assert.length result, 0

    'some DNs:["1001","2001"],username:"Agent1"': () ->
        n = 0
        db.some DNs:["1001","2001"],username:"Agent1", (value) ->
            n++
            assert.eql value, obj1
            return false
        assert.eql n, 1
        
    'some Switch:"SwitchA"': () ->
        n = 0
        db.some Switch:"SwitchA", (value) ->
            n++
            assert.includes [obj1,obj2,obj3], value
            return n >= 2
        assert.eql n, 2
        
    'forEach Switch:"SwitchA"': () ->
        n = 0
        db.forEach Switch:"SwitchA", (value) ->
            n++
            assert.includes [obj1,obj2,obj3], value
            return n >= 2
        assert.eql n, 3
        
     'set obj 4': () ->
        obj4.id = db.add obj4,
            username: 'Agent4'
            group: 'GroupB'
            DNs: ['1004','2004']
            Switch: 'SwitchA'
        assert.isDefined obj4.id
        return

    '2nd forEach Switch:"SwitchA"': () ->
        n = 0
        db.forEach Switch:"SwitchA", (value) ->
            n++
            assert.includes [obj1,obj2,obj3,obj4], value
            return n >= 2
        assert.eql n, 4
        return
        
    'remove obj4.id': () ->
        db.remove obj4.id
        assert.isNull db.getOne obj4.id
        return
        
     '2nd set obj 4': () ->
        obj4.id = db.add obj4,
            username: 'Agent4'
            group: 'GroupB'
            DNs: ['1004','2004']
            Switch: 'SwitchA'
        assert.isDefined obj4.id
        return

    'remove group:"GroupB"': () ->
        assert.eql 2, db.remove group:"GroupB"
        return
        
    'remove Switch:"SwitchB"': () ->
        assert.eql 0, db.remove Switch:"SwitchB"
        return

    'remove Switch:"SwitchA"': () ->
        assert.eql 2, db.remove Switch:"SwitchA"
        return
        
        
