(function() {
  /**
  This module allows you to index objects. 
  You can dynamically add any numbers of indexes to your objects. 
  */
  var MultiIndex, _someIndexes;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  MultiIndex = (function() {
    function MultiIndex() {
      this.indexes = {};
      this.data = {};
      this.nextId = 0;
    }
    /**
        Add an object into the store and optionaly index it.
        
        @param value {object} value to insert
        @param indexes (optional) {object} This optional parameter
               can use used to index the value. indexes is an object
               containing multiple index names and index values.
               Example: {username: 'John1', group:['GroupA','GroupB']}
        @return This function returns the id of the object. It must
                be used in the index function.
    */
    MultiIndex.prototype.add = function(value, indexes) {
      var id;
      id = ++this.nextId;
      this.data[id] = {
        indexes: {},
        id: id,
        value: value
      };
      if (indexes != null) {
        this.index(id, indexes);
      }
      return id;
    };
    /**
        Add indexes to an object identified by its id. This function may be called multiple
        times for a given object. Not all object requires the same indexes. Some object
        could be indexed by usernames while others could be indexed by countries.
        
        @param id This is the id of the object to index. This value is returned by the add 
               function.
        @param indexes {object} object containing multiple index names and index values.
               Example: {username: 'John1', group:'GroupA'}
        @return {void} nothing
        
    */
    MultiIndex.prototype.index = function(id, indexes) {
      var item;
      item = this.data[id];
      if (!(item != null)) {
        throw new Error('No existing item for provided id');
      }
      _someIndexes(indexes, __bind(function(indexName, indexValue) {
        if (!(this.indexes[indexName] != null)) {
          this.indexes[indexName] = {};
        }
        if (!(this.indexes[indexName][indexValue] != null)) {
          this.indexes[indexName][indexValue] = {};
        }
        this.indexes[indexName][indexValue][id] = true;
        if (!(item.indexes[indexName] != null)) {
          item.indexes[indexName] = {};
        }
        item.indexes[indexName][indexValue] = id;
        return false;
      }, this));
    };
    /**
        Remove object(s) and all their indexes off the store.
        
        @param indexes {object} Indexes to object(s) to be removed. All indexes pointing to this
               object don't need to be specified here. They will be automatically removed.
               Note that if indexes is of type string it is considered an id. This function will
               then remove the object having the given id.
        @return {Number} Returns the number of object(s) removed.
    */
    MultiIndex.prototype.remove = function(indexes) {
      var id, item, items, removed, _i, _len;
      removed = 0;
      items = [];
      if (typeof indexes === 'object') {
        items = this._get(indexes);
      } else {
        if (this.data[indexes] != null) {
          items.push(this.data[indexes]);
        }
      }
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        id = item.id;
        _someIndexes(item.indexes, __bind(function(indexName, indexValue) {
          delete this.indexes[indexName][indexValue][id];
          return false;
        }, this));
        delete this.data[id];
        removed++;
      }
      return removed;
    };
    /**
        This function iterates through the collection of objects under the provided indexes.
        Iteration stop when the callback returns true.
        
        @param indexes {object} object containing multiple index names and index values.
               Example: {username: 'John1', group:'GroupA'}
        @param callback {function} This function is called for every object found until the 
               callback returns true. The signature of the callback is as follow:
               function (value) {}
        @return {void} nothing
               
    */
    MultiIndex.prototype.some = function(indexes, callback) {
      this._some(indexes, function(item) {
        return callback(item.value);
      });
    };
    /**
        This function iterates through the collection of objects under the provided indexes.
        
        @param indexes {object} object containing multiple index names and index values.
               Example: {username: 'John1', group:'GroupA'}
        @param callback {function} This function is called for every object found. The
               signature of the callback is as follow: function (value) {}
        @return {void} nothing
    */
    MultiIndex.prototype.foreach = function(indexes, callback) {
      this.some(indexes, function(value) {
        callback(value);
        return false;
      });
    };
    /**
        Get all the object(s) under the provided indexes in an Array.
        @param indexes {object} object containing multiple index names and index values.
               Example: {username: 'John1', group:'GroupA'}
        @return {Array} An array containing all found objects.
    */
    MultiIndex.prototype.get = function(indexes) {
      var result;
      result = [];
      this.foreach(indexes, function(value) {
        result.push(value);
      });
      return result;
    };
    /**
        Get one (the first) object under the provided indexes.
        @param indexes {object} object containing multiple index names and index values.
               Example: {username: 'John1', group:'GroupA'}
        @return {object} The value found or null if not found
    */
    MultiIndex.prototype.getOne = function(indexes) {
      var result;
      result = null;
      /*
              _someIndexes indexes, (indexName, indexValue) => 
                  if @indexes[indexName]?[indexValue]?
                      ids = @indexes[indexName][indexValue]
                      for id of ids
                          if @data[id]?.value?
                              result = @data[id].value; 
                              return true 
                  return false
               */
      this.some(indexes, function(value) {
        result = value;
        return true;
      });
      return result;
    };
    MultiIndex.prototype._get = function(indexes) {
      var result;
      result = [];
      this._some(indexes, function(item) {
        result.push(item);
        return false;
      });
      return result;
    };
    MultiIndex.prototype._getOne = function(indexes) {
      var result;
      result = null;
      this._some(indexes, function(item) {
        result = item;
        return true;
      });
      return result;
    };
    MultiIndex.prototype._some = function(indexes, callback) {
      var tmp;
      tmp = {};
      _someIndexes(indexes, __bind(function(indexName, indexValue) {
        var id, ids, _ref;
        if (((_ref = this.indexes[indexName]) != null ? _ref[indexValue] : void 0) != null) {
          ids = this.indexes[indexName][indexValue];
          for (id in ids) {
            if (!tmp[id]) {
              tmp[id] = true;
              if (callback(this.data[id])) {
                return true;
              }
            }
          }
        }
        return false;
      }, this));
    };
    MultiIndex.prototype._setIndex = function(indexName, indexValue, id) {
      if (!(this.indexes[indexName] != null)) {
        this.indexes[indexName] = {};
      }
      if (!(this.indexes[indexName][indexValue] != null)) {
        this.indexes[indexName][indexValue] = {};
      }
      this.indexes[indexName][indexValue][id] = true;
    };
    return MultiIndex;
  })();
  /* example of indexes {DNs:['1234','2345'],username:'andrew',id:1243455}
      this would invoke callback 4 times:
      - callback 'DNs', '1234'
      - callback 'DNs', '2345'
      - callback 'username', 'andrew'
      - callback 'id', 1243455
  */
  _someIndexes = function(indexes, callback) {
    var indexName, indexValues, it;
    for (indexName in indexes) {
      indexValues = indexes[indexName];
      if (!Array.isArray(indexValues)) {
        if (typeof indexValues === "object") {
          indexValues = (function() {
            var _results;
            _results = [];
            for (it in indexValues) {
              _results.push(it);
            }
            return _results;
          })();
        } else {
          indexValues = [indexValues];
        }
      }
      indexValues.some(function(indexValue) {
        return callback(indexName, indexValue);
      });
    }
  };
  /*
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
  */
  module.exports = MultiIndex;
}).call(this);
