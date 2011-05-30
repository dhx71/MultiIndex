MultiIndex = require '../src/MultiIndex'
assert = require 'assert'
microtime = require 'microtime'

db = new MultiIndex
groupNames = ['GroupA', 'Supervisors', 'Admin', 'Outbound','GroupB']
switchNames = ['SwitchMTL', 'SwitchTor']

static = 
    data: {}
    indexes:
        username: {}
        tenant: {}
        group: {}
        DNs: {}
        Switch: {}

module.exports = 
    'set 5000 objects': () ->
        start = microtime.now()
        ret = null
        # 10000 inserts per second is not good enough!!!!
        for i in [1..5000]
            obj = i: i
            indexes =
                group: groupNames[i % 5]
                tenant: 'Resources'
                username: "Agent#{i}"
                DNs: ["#{10000+i}", "#{20000+i}"]
                Switch: switchNames[i % 2]
            ret = db.add obj, indexes
            assert.isDefined ret
            assert.isNotNull ret
        end = microtime.now()
        durationOk = end - start < 1000000
        console.log "'set 5000 objects' duration: #{(end-start)/1000} ms should be less than 1000 ms"
        assert.eql true, durationOk
        return


    'static insert 5000 objects': () ->
        start = microtime.now()
        for i in [1...5000]
            static.data[i] =
                i: i
            if not static.indexes.group[groupNames[i % 5]]?
                static.indexes.group[groupNames[i % 5]] = {}
            static.indexes.group[groupNames[i % 5]][i] = true
            static.indexes.tenant['Resources'] = {} if not static.indexes.tenant['Resources']?
            static.indexes.tenant['Resources'][i] = true
            static.indexes.username["Agent#{i}"] = {}
            static.indexes.username["Agent#{i}"][i] = true
            static.indexes.DNs["#{10000+i}"] = {}
            static.indexes.DNs["#{10000+i}"][i] = true
            static.indexes.DNs["#{20000+i}"] = {}
            static.indexes.DNs["#{20000+i}"][i] = true
            if not static.indexes.Switch[switchNames[i % 2]]?
                static.indexes.Switch[switchNames[i % 2]] = {} 
            static.indexes.Switch[switchNames[i % 2]][i] = true
        end = microtime.now()
        console.log "'static insert 5000 objects' duration: #{(end-start)/1000} ms"
        return

    '5000 getOne object by username': () ->
        start = microtime.now()
        for i in [1...5000]
            ret = db.getOne
                username: "Agent#{i}"
            assert.isDefined ret
            assert.isNotNull ret
        end = microtime.now()
        durationOk = end - start < 200000
        console.log "'5000 getOne object by username' duration: #{(end-start)/1000} ms should be less than 200 ms"
        assert.eql true, durationOk


    '5 get objects by group:"GroupB"': () ->
        start = microtime.now()
        for i in [1...5]
            ret = db.get
                group:"GroupB"
            assert.length ret, 1000
        end = microtime.now()
        durationOk = end - start < 1000000
        console.log "'5 get objects by group:GroupB' duration: #{(end-start)/1000} ms should be less than 1000 ms"
        assert.eql true, durationOk

    '50 some 50 objects by group:"GroupB"': () ->
        start = microtime.now()
        for i in [1...50]
            n=0
            db.some group:"GroupB", (value) ->
                return true if ++n is 50
                return false
            assert.eql n, 50
        end = microtime.now()
        durationOk = end - start < 50000
        console.log "'50 some 50 objects by group:GroupB' duration: #{(end-start)/1000} ms should be less than 50 ms"
        assert.eql true, durationOk

    'forEach tenant:Resources': () ->
        start = microtime.now()
        n=0
        db.forEach tenant:'Resources', (value) ->
            n++
            assert.isDefined value
            return
        end = microtime.now()
        durationOk = end - start < 20000
        console.log "'forEach tenant:Resources' duration: #{(end-start)/1000} ms should be less than 20 ms"
        assert.eql true, durationOk
        assert.eql 5000, n
        
