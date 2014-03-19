List of SVG elements

    svgElems = 'a altGlyph altGlyphDef altGlyphItem animate animateColor animateMotion
     animateTransform circle clipPath color-profile cursor defs desc ellipse
     feBlend feColorMatrix feComponentTransfer feComposite feConvolveMatrix
     feDiffuseLighting feDisplacementMap feDistantLight feFlood feFuncA feFuncB
     feFuncG feFuncR feGaussianBlur feImage feMerge feMergeNode feMorphology
     feOffset fePointLight feSpecularLighting feSpotLight feTile feTurbulence
     filter font font-face font-face-format font-face-name font-face-src
     font-face-uri foreignObject g glyph glyphRef hkern image line linearGradient
     marker mask metadata missing-glyph mpath path pattern polygon polyline
     radialGradient rect script set stop style svg symbol text textPath
     title tref tspan use view vkern'

List of HTML elements

    htmlElems = 'a abbr address article aside audio b bdi bdo blockquote body button
     canvas caption cite code colgroup datalist dd del details dfn div dl dt em
     fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
     html i iframe ins kbd label legend li main map mark menu meter nav noscript object
     ol optgroup option output p pre progress q rp rt ruby s samp script section
     select small span strong style sub summary sup table tbody td textarea tfoot
     th thead time title tr u ul video'

Weya object to be passed as `this`

    weya =
     elem: null

Wrapper for browser API

    Api =
     document: @document

Manipulating dom objects

    setStyles = (elem, styles) ->
     for k, v of styles
      if v?
       elem.style.setProperty k, v
      else
       elem.style.removeProperty k

    setEvents = (elem, events) ->
     for k, v of events
      elem.addEventListener k, v, false

    setAttributes = (elem, attrs) ->
     for k, v of attrs
      switch k
       when 'style' then setStyles elem, v
       when 'on' then setEvents elem, v
       else
        if v?
         elem.setAttribute k, v
        else
         elem.removeAttribute k

Parse id and class string

    parseIdClass = (str) ->
     res =
      id: null
      class: null

     for c, i in str.split "."
      if c.indexOf("#") is 0
       res.id = c.substr 1
      else if c isnt ""
       if not res.class?
        res.class = c
       else
        res.class += " #{c}"

     return res


Append a child element

    append = (ns, name, args) ->
     idClass = null
     contentText = null
     attrs = null
     contentFunction = null

     for arg, i in args
      switch typeof arg
       when 'function' then contentFunction = arg
       when 'object' then attrs = arg
       when 'string'
        if args.length is 1
         contentText = arg
        else
         c = arg.charAt 0

         if i is 0 and (c is '#' or c is '.')
          idClass = arg
         else
          contentText = arg

Keep a reference to parent element

     pElem = @_elem

Keep a reference of `elem` to return at the end of the function

     if ns?
      elem = @_elem = Api.document.createElementNS ns, name
     else
      elem = @_elem = Api.document.createElement name

     if idClass?
      idClass = parseIdClass idClass
      if idClass.id?
       elem.id = idClass.id
      if idClass.class?
       elem.className = idClass.class

     if attrs?
      setAttributes elem, attrs

     if pElem?
      pElem.appendChild elem

     if contentFunction?
      contentFunction.call @
     else if contentText?
      elem.textContent = contentText

     @_elem = pElem
     return elem

Wrap `append`

    wrapAppend = (ns, name) ->
     ->
      append.call @, ns, name, arguments


Initialize

    for name in svgElems.split ' '
     weya[name] = wrapAppend "http://www.w3.org/2000/svg", name

    for name in htmlElems.split ' '
     weya[name] = wrapAppend null, name

#Weya

Create an append to `elem`. If `self` is provied it can be accessed via `@this`.

    @Weya = Weya = (elem, self, func) ->
     if (typeof self) is 'function'
      func = self
      self = null
     pSelf = weya.this
     weya.this = self
     pElem = weya._elem
     weya._elem = elem
     r = func?.call weya
     weya._elem = pElem
     weya.this = pSelf
     return r

Create elements without appending

    Weya.create = (self, func) -> Weya null, self, func
