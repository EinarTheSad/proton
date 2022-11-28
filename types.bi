TYPE FontCharInfo
    CharWidth AS INTEGER
    CharHeight AS INTEGER
    FileOffset AS LONG
END TYPE

TYPE BMPHeaderType
    id AS STRING * 2 'Should be "BM"
    size AS LONG 'Size of the data
    rr1 AS INTEGER
    rr2 AS INTEGER
    offset AS LONG 'Position of start of pixel data
    horz AS LONG
    wid AS LONG 'Image width
    hei AS LONG 'Image height
    planes AS INTEGER
    bpp AS INTEGER 'Should read 8 for a 256 colour image
    pakbyte AS LONG
    imagebytes AS LONG 'Width*Height
    xres AS LONG
    yres AS LONG
    colch AS LONG
    ic AS LONG
    pal AS STRING * 1024
END TYPE

TYPE Form
    x AS INTEGER
    y AS INTEGER
    w AS INTEGER
    h AS INTEGER
    title AS STRING * 64
    isFocus AS INTEGER
END TYPE

TYPE Button
	x AS INTEGER
    y AS INTEGER
    w AS INTEGER
    h AS INTEGER
	label AS STRING * 16
	color AS INTEGER
	isClicked AS INTEGER
END TYPE