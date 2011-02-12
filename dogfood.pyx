import jsonlib


def food_handler(obj):
    if hasattr(obj, '__food__'):
        item = obj.__encode__()
        item.append('__food__')
        return item
    raise jsonlib.UnknownSerializerError

def encode_food(thing):
    #listed = deflate_food(thing)
    #bytes = zlib.compress(json.dumps(listed), 1)
    bytes = jsonlib.write(thing, on_unknown=food_handler)
    return bytes

def deflate_food(thing):
    if hasattr(thing, '__food__'):
        thing_list = thing.__encode__()
        obj_name = thing_list[0]
        obj_args = thing_list[1]
        for index, arg in enumerate(obj_args):
            obj_args[index] = deflate_food(arg)
        return [obj_name, obj_args, '__food__']

    if type(thing) == dict:
        out_dict = dict(thing)
        for key, val in thing.iteritems():
            del(out_dict[key])
            out_dict[deflate_food(key)] = deflate_food(val)
        return out_dict

    if type(thing) == list:
        out_list = list(thing)
        for nindex, item in enumerate(thing):
            out_list[nindex] = deflate_food(item)
        return out_list

    return thing

def decode_food(encoded):
    #encoded = zlib.decompress(encoded)
    obj = jsonlib.loads(encoded)
    return inflate_food(obj)

def is_food(oname):
    return hasattr(globals()[oname], '__food__')

def can_be_food(alist):
    return type(alist) == list and len(alist) == 3 and alist[2] == '__food__'

def inflate_food(thing):
    if len(thing) == 3 and thing[2] == '__food__':
        if thing[0] in filter(is_food, globals().keys()):
            # Inflate args too
            for index, arg in enumerate(thing[1]):
                if type(arg) == list and len(arg) == 3 and arg[2] == '__food__':
                    thing[1][index] = inflate_food(arg)
                    continue
                if type(arg) == list:
                    for nindex, item in enumerate(arg):
                        if can_be_food(item):
                            thing[1][index][nindex] = inflate_food(item)
                if type(arg) == dict:
                    for key, val in arg.iteritems():
                        if can_be_food(val):
                            thing[1][index][key] = inflate_food(val)
                        if can_be_food(key):
                            thing[1][index][inflate_food(key)] = val
                            del(thing[1][index][key])
            # deref the object and make a new one
            exe = globals()[thing[0]]
            return exe(*thing[1])
    return thing


cdef class Food:

    cdef public __food__

