open MongoUtils;;

let send_no_reply_ (_,out_ch) request_str =
  let%lwt _ = Lwt_io.write out_ch request_str in
  Lwt_io.flush out_ch;;

let send_no_reply channel_pool request_str =
  Lwt_pool.use channel_pool (
    fun c -> send_no_reply_ c request_str
  )

(* read complete reply portion, include complete message header *)
let read_reply (in_ch,_) =
  let chr0 = Char.chr 0 in
  let len_str = Bytes.make 4 chr0 in
  let%lwt _ = Lwt_io.read_into_exactly in_ch len_str 0 4 in
  let (len32, _) = decode_int32 (Bytes.to_string len_str) 0 in
  let len = Int32.to_int len32 in
  (*print_endline (Int32.to_string len32);*)
  let str = Bytes.make (len-4) chr0 in
  let%lwt _ = Lwt_io.read_into_exactly in_ch str 0 (len-4) in
  let buf = Buffer.create len in
  Buffer.add_bytes buf len_str;
  Buffer.add_bytes buf str;
  Lwt.return (Buffer.contents buf)

let send_with_reply channel_pool request_str =
  Lwt_pool.use channel_pool (
    fun channels ->
      let%lwt _ = send_no_reply_ channels request_str in
      let%lwt r = read_reply channels in
      let dr = MongoReply.decode_reply r in
      Lwt.return dr
  )
