#!/usr/bin/env elixir

defmodule DiskMap do
  def parse(map, :part_1) do
    map
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> construct_disk()
    |> Enum.reverse()
  end

  def parse(map, :part_2) do
    blocks = parse(map, :part_1)

    {free_chunks, file_chunks} =
      blocks
      |> Enum.chunk_by(&elem(&1, 1))
      |> Enum.map(fn [{_, file_id} | _] = blocks -> {Enum.map(blocks, &elem(&1, 0)), file_id} end)
      |> Enum.split_with(&(elem(&1, 1) == :free_block))

    {free_chunks |> Enum.map(fn {block_ids, :free_block} -> {block_ids, length(block_ids)} end),
     file_chunks |> Enum.reverse()}
  end

  defp construct_disk(disk_map) do
    construct_disk(disk_map, :file_block, 0, 0, [])
  end

  defp construct_disk([0 | tail], :file_block, block_id, file_id, acc) do
    construct_disk(tail, :free_block, block_id, file_id + 1, acc)
  end

  defp construct_disk([0 | tail], :free_block, block_id, file_id, acc) do
    construct_disk(tail, :file_block, block_id, file_id, acc)
  end

  defp construct_disk([head | tail], :file_block, block_id, file_id, acc) do
    construct_disk([head - 1 | tail], :file_block, block_id + 1, file_id, [
      {block_id, file_id} | acc
    ])
  end

  defp construct_disk([head | tail], :free_block, block_id, file_id, acc) do
    construct_disk([head - 1 | tail], :free_block, block_id + 1, file_id, [
      {block_id, :free_block} | acc
    ])
  end

  defp construct_disk([], _, _, _, acc) do
    acc
  end

  def compress_disk(blocks) do
    compress_disk(
      blocks,
      Enum.filter(blocks |> Enum.reverse(), fn {_, id} -> id != :free_block end),
      []
    )
  end

  defp compress_disk(
         [{block_id, :free_block} | blocks],
         [{file_block_id, file_id} | file_blocks],
         acc
       )
       when block_id <= file_block_id do
    compress_disk(blocks, file_blocks, [{block_id, file_id} | acc])
  end

  defp compress_disk([{block_id, file_id} | blocks], [{file_block_id, _} | _] = file_blocks, acc)
       when block_id <= file_block_id do
    compress_disk(blocks, file_blocks, [{block_id, file_id} | acc])
  end

  defp compress_disk(_, _, acc) do
    acc
  end

  def compute_checksum(blocks, :part_1) do
    blocks
    |> Enum.reduce(0, fn {block_id, file_id}, acc ->
      acc + block_id * file_id
    end)
  end

  def compute_checksum(blocks, :part_2) do
    blocks
    |> Enum.reduce(0, fn
      {block_ids, file_id}, acc when is_integer(file_id) ->
        Enum.reduce(block_ids, acc, fn block_id, acc -> acc + block_id * file_id end)
    end)
  end

  def defrag({free_chunks, file_chunks}) do
    defrag(file_chunks, free_chunks, [])
  end

  defp defrag(
         [{[low_block_id | _] = block_ids, file_id} = head | file_chunks],
         [{[high_free_block_id | _], _} | _] = free_chunks,
         acc
       )
       when high_free_block_id < low_block_id do
    case take_space(free_chunks, block_ids) do
      {[free_block_id | _] = free_block_ids, free_chunks} when free_block_id < low_block_id ->
        defrag(file_chunks, free_chunks, [{free_block_ids, file_id} | acc])

      _ ->
        defrag(file_chunks, free_chunks, [head | acc])
    end
  end

  defp defrag(file_chunks, _, acc) do
    file_chunks ++ acc
  end

  defp take_space(free_chunks, block_ids) do
    take_space(free_chunks, length(block_ids), [])
  end

  defp take_space([{free_block_ids, free_block_ids_len} | free_chunks], block_ids_len, skipped)
       when block_ids_len < free_block_ids_len do
    {used_block_ids, rest} = Enum.split(free_block_ids, block_ids_len)

    {used_block_ids,
     skipped |> Enum.reverse([{rest, free_block_ids_len - block_ids_len} | free_chunks])}
  end

  defp take_space([{free_block_ids, len} | free_chunks], len, skipped) do
    {free_block_ids, skipped |> Enum.reverse(free_chunks)}
  end

  defp take_space([skip | rest], len, skipped) do
    take_space(rest, len, [skip | skipped])
  end

  defp take_space([], _, _) do
    nil
  end
end

argv = System.argv()

if length(argv) != 1 do
  IO.puts(:stderr, "Usage: 2024/day-08/nain.exs <file>")
  System.stop(64)
end

checksum =
  argv
  |> hd()
  |> File.read!()
  |> String.trim()
  |> DiskMap.parse(:part_1)
  |> DiskMap.compress_disk()
  |> DiskMap.compute_checksum(:part_1)

IO.puts("Part 1: #{checksum}")

checksum =
  argv
  |> hd()
  |> File.read!()
  |> String.trim()
  |> DiskMap.parse(:part_2)
  |> DiskMap.defrag()
  |> DiskMap.compute_checksum(:part_2)

IO.puts("Part 2: #{checksum}")
