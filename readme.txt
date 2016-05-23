## Property Converter
A short Perl script to convert Python fget/fset functions to use the `@property` syntax.

## How to use
1. Set `$dir` to locate the directory you'd like to [recursively] process.
2. Set `$work_on_string` to one of `fget` or `fset` (see below for what these options do).
3. Run `property_conversion.pl`

## What it does
The script converts code blocks from one form to another. `fget` and
`fget`/`fset` code blocks are parsed and converted completely separately.

Some notes:

- Only processes functions that satisfy the following structure exactly. Correctness is
more important than complete codebase coverage.
- Functions must have a docstring.
- Functions may have a single extra newline between certain blocks.
- Files must have unix line endings.
- Only operates on `.py` files.

### fget mode
#### Original

    def code(): #@NoSelf
        def fget(self):
            return self.__dict__["code"]
        return locals()
    code = property(**code())
    """
        Getter:
        =======
        Returns the currency code.

        @rtype: UnicodeType

        @postcondition: len(return) > 0

        Setter:
        =======
        Not settable.
    """

#### Convertion

    @property
    def code(self):
        """
            Returns the currency code.

            @rtype: UnicodeType

            @postcondition: len(return) > 0
        """
        return self.__dict__["code"]

### fget/fset mode
#### Original

    def message(): #@NoSelf
        def fget(self):
            return self.__message
        def fset(self, value):
            assert isinstance(value, (UnicodeType, StringType,))
            self.__message = value
        return locals()

    message = property(**message())
    """
        Getter:
        =======
        Gets the message for this error

        @rtype: UnicodeType or StringType

        Setter:
        =======
        Sets the message for this error

        @type value: UnicodeType or StringType
    """

#### Conversion

    @property
    def message(self):
        """
            Gets the message for this error

            @rtype: UnicodeType or StringType
        """
        return self.__message

    @message.setter
    def message(self, value):
        """
            Sets the message for this error

            @type value: UnicodeType or StringType
        """
        assert isinstance(value, (UnicodeType, StringType,))
        self.__message = value

## License
Made available under the MIT license.
