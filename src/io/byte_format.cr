# Defines a byte format to encode integers and floats
# from/to `Bytes` and `IO`.
#
# ### Decode from bytes
#
# ```
# bytes = Bytes[0x34, 0x12]
# int16 = IO::ByteFormat::LittleEndian.decode(Int16, bytes)
# int16 # => 0x1234_i16
# ```
#
# ### Decode from an IO
#
# ```
# io = IO::Memory.new(Bytes[0x34, 0x12])
# int16 = io.read_bytes(Int16, IO::ByteFormat::LittleEndian)
# int16 # => 0x1234_i16
# ```
#
# ### Encode to bytes
#
# ```
# bytes = uninitialized UInt8[2]
# IO::ByteFormat::LittleEndian.encode(0x1234_i16, bytes.to_slice)
# bytes # => Bytes[0x34, 0x12]
# ```
#
# ### Encode to IO
#
# ```
# io = IO::Memory.new
# io.write_bytes(0x1234_i16, IO::ByteFormat::LittleEndian)
# io.to_slice # => Bytes[0x34, 0x12]
# ```
module IO::ByteFormat
  abstract def encode(int : Int8, io : IO)
  abstract def encode(int : UInt8, io : IO)
  abstract def encode(int : Int16, io : IO)
  abstract def encode(int : UInt16, io : IO)
  abstract def encode(int : Int32, io : IO)
  abstract def encode(int : UInt32, io : IO)
  abstract def encode(int : Int64, io : IO)
  abstract def encode(int : UInt64, io : IO)
  abstract def encode(int : Float32, io : IO)
  abstract def encode(int : Float64, io : IO)

  abstract def encode(int : Int8, bytes : Bytes)
  abstract def encode(int : UInt8, bytes : Bytes)
  abstract def encode(int : Int16, bytes : Bytes)
  abstract def encode(int : UInt16, bytes : Bytes)
  abstract def encode(int : Int32, bytes : Bytes)
  abstract def encode(int : UInt32, bytes : Bytes)
  abstract def encode(int : Int64, bytes : Bytes)
  abstract def encode(int : UInt64, bytes : Bytes)
  abstract def encode(int : Float32, bytes : Bytes)
  abstract def encode(int : Float64, bytes : Bytes)

  abstract def decode(int : Int8.class, io : IO)
  abstract def decode(int : UInt8.class, io : IO)
  abstract def decode(int : Int16.class, io : IO)
  abstract def decode(int : UInt16.class, io : IO)
  abstract def decode(int : Int32.class, io : IO)
  abstract def decode(int : UInt32.class, io : IO)
  abstract def decode(int : Int64.class, io : IO)
  abstract def decode(int : UInt64.class, io : IO)
  abstract def decode(int : Float32.class, io : IO)
  abstract def decode(int : Float64.class, io : IO)

  abstract def decode(int : Int8.class, bytes : Bytes)
  abstract def decode(int : UInt8.class, bytes : Bytes)
  abstract def decode(int : Int16.class, bytes : Bytes)
  abstract def decode(int : UInt16.class, bytes : Bytes)
  abstract def decode(int : Int32.class, bytes : Bytes)
  abstract def decode(int : UInt32.class, bytes : Bytes)
  abstract def decode(int : Int64.class, bytes : Bytes)
  abstract def decode(int : UInt64.class, bytes : Bytes)
  abstract def decode(int : Float32.class, bytes : Bytes)
  abstract def decode(int : Float64.class, bytes : Bytes)

  def encode(float : Float32, io : IO)
    encode(pointerof(float).as(Int32*).value, io)
  end

  def encode(float : Float32, bytes : Bytes)
    encode(pointerof(float).as(Int32*).value, bytes)
  end

  def decode(type : Float32.class, io : IO)
    int = decode(Int32, io)
    pointerof(int).as(Float32*).value
  end

  def decode(type : Float32.class, bytes : Bytes)
    int = decode(Int32, bytes)
    pointerof(int).as(Float32*).value
  end

  def encode(float : Float64, io : IO)
    encode(pointerof(float).as(Int64*).value, io)
  end

  def encode(float : Float64, bytes : Bytes)
    encode(pointerof(float).as(Int64*).value, bytes)
  end

  def decode(type : Float64.class, io : IO)
    int = decode(Int64, io)
    pointerof(int).as(Float64*).value
  end

  def decode(type : Float64.class, bytes : Bytes)
    int = decode(Int64, bytes)
    pointerof(int).as(Float64*).value
  end

  module LittleEndian
    extend ByteFormat
  end

  module BigEndian
    extend ByteFormat
  end

  alias SystemEndian = LittleEndian
  alias NetworkEndian = BigEndian

  {% for mod in %w(LittleEndian BigEndian) %}
    module {{mod.id}}
      {% for type, i in %w(Int8 UInt8 Int16 UInt16 Int32 UInt32 Int64 UInt64) %}
        def self.encode(int : {{type.id}}, io : IO)
          buffer = pointerof(int).as(UInt8[{{2 ** (i / 2)}}]*).value
          buffer.reverse! unless SystemEndian == self
          io.write(buffer.to_slice)
        end

        def self.encode(int : {{type.id}}, bytes : Bytes)
          buffer = pointerof(int).as(UInt8[{{2 ** (i / 2)}}]*).value
          buffer.reverse! unless SystemEndian == self
          buffer.to_slice.copy_to(bytes)
        end

        def self.decode(type : {{type.id}}.class, io : IO)
          buffer = uninitialized UInt8[{{2 ** (i / 2)}}]
          io.read_fully(buffer.to_slice)
          buffer.reverse! unless SystemEndian == self
          buffer.to_unsafe.as(Pointer({{type.id}})).value
        end

        def self.decode(type : {{type.id}}.class, bytes : Bytes)
          buffer = uninitialized UInt8[{{2 ** (i / 2)}}]
          bytes.copy_to(buffer.to_slice)
          buffer.reverse! unless SystemEndian == self
          buffer.to_unsafe.as(Pointer({{type.id}})).value
        end
      {% end %}
    end
  {% end %}
end
