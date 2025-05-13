defmodule Encriptador do
  @clave_secreta "1234567890123456" # 16 bytes exactos
  @modo :aes_128_ecb
  @block_size 16

  # Encripta texto plano con PKCS7 y lo retorna en Base64
  def encriptar(texto) when is_binary(texto) do
    texto
    |> aplicar_padding_pkcs7()
    |> then(& :crypto.crypto_one_time(@modo, @clave_secreta, &1, true))
    |> Base.encode64()
  end

  # Desencripta texto en Base64 con limpieza de saltos de línea
  def desencriptar(texto_base64) when is_binary(texto_base64) do
    texto_base64
    |> limpiar_base64()
    |> Base.decode64!()
    |> then(& :crypto.crypto_one_time(@modo, @clave_secreta, &1, false))
    |> quitar_padding_pkcs7()
  end

  # Limpieza de saltos de línea o espacios
  defp limpiar_base64(texto) do
    texto
    |> String.trim()
    |> String.replace("\r", "")
    |> String.replace("\n", "")
  end

  # Añade padding PKCS#7 manualmente
  defp aplicar_padding_pkcs7(texto) do
    pad_len = @block_size - rem(byte_size(texto), @block_size)
    padding = :binary.copy(<<pad_len>>, pad_len)
    texto <> padding
  end

  # Elimina padding PKCS#7 después del descifrado
  defp quitar_padding_pkcs7(texto) do
    <<_::binary-size(byte_size(texto) - 1), last_byte>> = texto
    pad_len = last_byte
    texto_size = byte_size(texto)

    if pad_len in 1..@block_size do
      <<unpadded::binary-size(texto_size - pad_len), _::binary>> = texto
      unpadded
    else
      texto
    end
  end
end
