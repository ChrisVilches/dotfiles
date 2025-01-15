local Stack = {}

function Stack:new()
  local instance = {
    _stack = {},
    count = 0,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Stack:clear()
  self._stack = {}
  self.count = 0
end

function Stack:push(obj)
  self.count = self.count + 1
  self._stack[self.count] = obj
end

function Stack:pop()
  if self.count == 0 then
    return nil
  end
  local value = self._stack[self.count]
  self._stack[self.count] = nil
  self.count = self.count - 1
  return value
end

function Stack:is_empty()
  return self.count == 0
end

return {
  Stack = Stack,
}
