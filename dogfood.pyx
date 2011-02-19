import jsonlib


def _food_handler(obj):
    if hasattr(obj, '__food__'):
        item = obj.__encode__()
        item.append('__food__')
        return item
    raise jsonlib.UnknownSerializerError

def encode(thing):
    bytes = jsonlib.write(thing, on_unknown=_food_handler)
    return bytes

def _deflate(thing):
    if hasattr(thing, '__food__'):
        thing_list = thing.__encode__()
        obj_name = thing_list[0]
        obj_args = thing_list[1]
        if len(thing_list) == 3:
            obj_kwargs = thing_list[2]
        else:
            obj_kwargs = None
        for index, arg in enumerate(obj_args):
            obj_args[index] = _deflate(arg)
        obj_kwargs = _deflate(obj_kwargs)
        return [obj_name, obj_args, obj_kwargs, '__food__']

    if type(thing) == dict:
        out_dict = dict(thing)
        for key, val in thing.iteritems():
            del(out_dict[key])
            out_dict[_deflate(key)] = _deflate(val)
        return out_dict

    if type(thing) == list:
        out_list = list(thing)
        for nindex, item in enumerate(thing):
            out_list[nindex] = _deflate(item)
        return out_list

    return thing

def decode(encoded):
    obj = jsonlib.loads(encoded)
    return _inflate(obj)

def _is_food(oname):
    return hasattr(globals()[oname], '__food__')

def _can_be_food(alist):
    return type(alist) == list and len(alist) == 3 and alist[2] == '__food__'

def _inflate(thing):
    if thing[-1] == '__food__':
        if thing[0] in filter(_is_food, globals().keys()):
            # Inflate args too
            for index, arg in enumerate(thing[1]):
                if type(arg) == list and len(arg) == 3 and arg[2] == '__food__':
                    thing[1][index] = _inflate(arg)
                    continue
                if type(arg) == list:
                    for nindex, item in enumerate(arg):
                        if _can_be_food(item):
                            thing[1][index][nindex] = _inflate(item)
                if type(arg) == dict:
                    for key, val in arg.iteritems():
                        if _can_be_food(val):
                            thing[1][index][key] = _inflate(val)
                        if _can_be_food(key):
                            thing[1][index][_inflate(key)] = thing[1][index][key]
                            del(thing[1][index][key])
            if len(thing) == 4 and type(thing[2]) == dict:
                dthing = dict(thing[2])
                for key, val in dthing.iteritems():
                    if _can_be_food(val):
                        thing[2][key] = _inflate(val)
                    if _can_be_food(key):
                        thing[2][_inflate(key)] = thing[2][key]
                        del(thing[2][key])
                kwargs = thing[2]
            else:
                kwargs = {}
            # deref the object and make a new one
            exe = globals()[thing[0]]
            return exe(*thing[1], **kwargs)
    return thing


cdef class Food:

    cdef public __food__
