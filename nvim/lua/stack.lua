function Stack()
  return setmetatable({
    _stack = {},
    count = 0,

    clear = function(self)
      self._stack = {}
      self.count = 0
    end,

    push = function(self, obj)
      self.count = self.count + 1
      rawset(self._stack, self.count, obj)
    end,

    pop = function(self)
      self.count = self.count - 1
      return table.remove(self._stack)
    end,

    is_empty = function(self)
      return self.count == 0
    end,
  }, {
    -- TODO: Is this for the setmetatable thingy?? Do I need it?
    __index = function(self, index)
      return rawget(self._stack, index)
    end,
  })
end

return {
  Stack = Stack,
}
