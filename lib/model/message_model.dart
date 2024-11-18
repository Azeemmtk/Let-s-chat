class MessageModel {
  MessageModel({
    required this.msg,
    required this.toid,
    required this.read,
    required this.type,
    required this.fromid,
    required this.send,
  });
  late final String msg;
  late final String toid;
  late final String read;
  late final String fromid;
  late final String send;
  late final Type type;

  MessageModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    toid = json['toid'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    fromid = json['fromid'].toString();
    send = json['send'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['toid'] = toid;
    data['read'] = read;
    data['type'] = type.name;
    data['fromid'] = fromid;
    data['send'] = send;
    return data;
  }
}

enum Type { text, image }
