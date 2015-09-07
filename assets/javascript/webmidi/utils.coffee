class @Util
  @getFirstValue: (object, value) ->
    for prop in this
      if this.hasOwnProperty( prop )
        return prop;