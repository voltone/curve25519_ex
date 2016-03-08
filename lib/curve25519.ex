defmodule Curve25519 do
  import Bitwise


  defp p, do: 57896044618658097711785492504343953926634992332820282019728792003956564819949
  defp a, do: 486662

  defp clamp(c) do
    c |> band(~~~7)
      |> band(~~~(128 <<< 8 * 31))
      |> bor(64 <<< 8 * 31)
  end

  defp square(x), do: x * x

  defp expmod(_b,0,_m), do: 1
  defp expmod(b,e,m) do
       t = b |> expmod(div(e,2), m) |> square |> rem(m)
       if (e &&& 1) == 1, do: (t * b) |> rem(m), else: t
  end

  defp inv(x), do: x|> expmod(p - 2, p)

  defp add({xn,zn}, {xm,zm}, {xd,zd}) do
       x = (xm * xn - zm * zn) |> square |> (&(&1 * 4 * zd)).()
       z = (xm * zn - zm * xn) |> square |> (&(&1 * 4 * xd)).()
       {rem(x,p), rem(z,p)}
  end
  defp double({xn,zn}) do
       x = (square(xn) - square(zn)) |> square
       z = 4 * xn * zn * (square(xn) + a * xn * zn + square(zn))
      {rem(x,p),  rem(z,p)}
  end

  defp curve25519(n, base) do
    one = {base,1}
    two = double(one)
    {{x,z}, _} = nth_mult(n, {one,two})
    (x * inv(z)) |> rem(p)
  end

  defp nth_mult(1, basepair), do: basepair
  defp nth_mult(n, {one,two}) do
     {pm, pm1} = n |> div(2) |> nth_mult({one,two})
     if (n &&& 1) == 1, do: { add(pm, pm1, one), double(pm1) }, else: { double(pm), add(pm, pm1, one) }
  end

  def generate_key_pair do
    secret = :crypto.strong_rand_bytes(32) # This algorithm is supposed to be resilient against poor RNG, but use the best we can
    {secret, derive_public_key(secret)}
  end

  def derive_shared_secret(our_secret, their_public) do
    our_secret |> :binary.decode_unsigned(:little)
               |> clamp
               |> curve25519(:binary.decode_unsigned(their_public, :little))
               |> :binary.encode_unsigned(:little)
  end

  def derive_public_key(our_secret) do
    our_secret |> :binary.decode_unsigned(:little)
               |> clamp
               |> curve25519(9)
               |> :binary.encode_unsigned(:little)
  end

end
