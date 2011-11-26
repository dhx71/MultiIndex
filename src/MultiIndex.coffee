###*
This module allows you to index objects. 
You can dynamically add any numbers of indexes to your objects. 
###

class MultiIndex

    constructor: () ->
        @indexes = {}
        @data = {}
        @nextId = 0
        
    ###*
        Add an object into the store and optionaly index it.
        
        @param value {object} value to insert
        @param indexes (optional) {object} This optional parameter
               can use used to index the value. indexes is an object
               containing multiple index names and index values.
               Example: {username: 'John1', group:['GroupA','GroupB']}
        @return This function returns the id of the object. It must
                be used in the index function.
    ###
    add: (value, indexes) ->
        id = ++@nextId
        @data[id] = 
            indexes: {}
            id: id
            value: value
        
        @index id, indexes if indexes?
        return id

    ###*
        Add indexes to an object identified by its id. This function may be called multiple
        times for a given object. Not all object requires the same indexes. Some object
        could be indexed by usernames while others could be indexed by countries.
        
        @param id This is the id of the object to index. This value is returned by the add 
               function.
        @param indexes {object} object containing multiple index names and index values.
               Example: {username: 'John1', group:'GroupA'}
        @return {void} nothing
        
    ###
    index: (id, indexes) ->
        item = @data[id]
        if not item? 
            throw new Error 'No existing item for provided id'

        _someIndexes indexes, (indexName, indexValue) =>
            # set indexes
            @indexes[indexName] = {} if not @indexes[indexName]?
            @indexes[indexName][indexValue] = {} if not @indexes[indexName][indexValue]?
            @indexes[indexName][indexValue][id] = true

            # update item's index (used when removing indexes & item)
            item.indexes[indexName] = {} if not item.indexes[indexName]?
            item.indexes[indexName][indexValue] = id
            return false
        return

    ###*
        Remove object(s) and all their indexes off the store.
        
        @param indexes {object} Indexes to object(s) to be removed. All indexes pointing to this
               object don't need to be specified here. They will be automatically removed.
               Note that if indexes is of type string it is considered an id. This function will
               then remove the object having the given id.
        @return {Number} Returns the number of object(s) removed.
    ###
    remove: (indexes) ->
        removed = 0
        items = []
        if typeof indexes is 'object'
            items = @_get indexes
        else
            items.push @data[indexes] if @data[indexes]?
        for item in items
            # delete all indexes to this item
            id = item.id
            _someIndexes item.indexes, (indexName, indexValue) =>
                delete @indexes[indexName][indexValue][id]
                return false
            # delete actual item
            delete @data[id]
            removed++
        return removed

    ###*
        This function iterates through the collection of objects under the provided indexes.
        Iteration stop when the callback returns true.
        
        @param indexes {object} object containing multiple index names and index values.
               Example: {username: 'John1', group:'GroupA'}
        @param callback {function} This function is called for every object found until the 
               callback returns true. The signature of the callback is as follow:
               function (value) {}
        @return {void} nothing
               
    ###
    some: (indexes, callback) ->
        @_some indexes, (item) ->
            return callback item.value
        return

    ###*
        This function iterates through the collection of objects under the provided indexes.
        
        @param indexes {object} object containing multiple index names and index values.
               Example: {username: 'John1', group:'GroupA'}
        @param callback {function} This function is called for every object found. The
               signature of the callback is as follow: function (value) {}
        @return {void} nothing
    ###
    foreach: (indexes, callback) ->
        @some indexes, (value) ->
            callback value
            return false
        return
    
    ###*
        Get all the object(s) under the provided indexes in an Array.
        @param indexes {object} object containing multiple index names and index values.
               Example: {username: 'John1', group:'GroupA'}
        @return {Array} An array containing all found objects.
    ###
    get: (indexes) ->
        result = []
        @foreach indexes, (value) ->
            result.push value
            return
        return result

    ###*
        Get one (the first) object under the provided indexes.
        @param indexes {object} object containing multiple index names and index values.
               Example: {username: 'John1', group:'GroupA'}
        @return {object} The value found or null if not found
    ###
    getOne: (indexes) ->
        result = null
        ###
        _someIndexes indexes, (indexName, indexValue) => 
            if @indexes[indexName]?[indexValue]?
                ids = @indexes[indexName][indexValue]
                for id of ids
                    if @data[id]?.value?
                        result = @data[id].value; 
                        return true 
            return false
         ###
        @some indexes, (value) ->
            result = value
            return true
        return result

    #private:
    _get: (indexes) ->
        result = []
        @_some indexes, (item) ->
            result.push item
            return false
        return result
    
    _getOne: (indexes) ->
        result = null
        @_some indexes, (item) ->
            result = item
            return true
#        console.log "get one for #{indexes[@masterIndexName]} returned #{result.indexes[@masterIndexName]}"
        return result

    
    _some: (indexes, callback) ->
        tmp = {}
        # collect all unique id for provided indexes
        _someIndexes indexes, (indexName, indexValue) => 
            if @indexes[indexName]?[indexValue]?
                ids = @indexes[indexName][indexValue]
                for id of ids
                    if not tmp[id]
                        tmp[id] = true
                        return true if callback @data[id]
                        
            return false
            
        # invoke callback. @indexes & @data can be altered without affecting this loop
#        for id of tmp
#            if callback @data[id]
#                break
        return

    _setIndex: (indexName, indexValue, id) ->
        @indexes[indexName] = {} if not @indexes[indexName]?
        @indexes[indexName][indexValue] = {} if not @indexes[indexName][indexValue]?
        @indexes[indexName][indexValue][id] = true
        return

# static private
### example of indexes {DNs:['1234','2345'],username:'andrew',id:1243455}
    this would invoke callback 4 times:
    - callback 'DNs', '1234'
    - callback 'DNs', '2345'
    - callback 'username', 'andrew'
    - callback 'id', 1243455
###
_someIndexes = (indexes, callback) ->
    for indexName of indexes
        indexValues = indexes[indexName]
        if not Array.isArray indexValues
            if typeof indexValues is "object"
                indexValues = (it for it of indexValues)
            else
                indexValues = [indexValues]
        indexValues.some (indexValue) -> 
            return callback indexName, indexValue
    return

###
data = new MultiIndex 'id'

data.set {'id': 1}, {text: 'salut'}

data.index 
    id: 1
    ip: client.connection.remoteAddress   # add index ip
    username: username                    # add index username
    group:groupname                       # add index group
    DNs: ['2434:SwitchA', '3434:SwitchA'] # add index DNs

data.index 
    username: username
    tenant:'xyz'                          # add index tenant
    
user = data.getOne username: 'Agent1'

# remove data and all indexes
data.remove ip: client.connection.remoteAddress
###    
module.exports = MultiIndex
    

