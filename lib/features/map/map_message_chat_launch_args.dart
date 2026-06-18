import 'package:secret_location_chat/data/models/geo_message_model.dart';

class MapMessageChatLaunchArgs {
  final GeoMessage parentMessage;
  final bool isAnonymous;

  const MapMessageChatLaunchArgs({
    required this.parentMessage,
    this.isAnonymous = false,
  });
}
