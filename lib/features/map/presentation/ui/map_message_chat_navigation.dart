import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/data/geo/geo_message_repository.dart';
import 'package:secret_location_chat/data/models/geo_message_model.dart';
import 'package:secret_location_chat/data/models/user_log_event.dart';
import 'package:secret_location_chat/features/map/map_message_chat_launch_args.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/map_bloc.dart';

Future<void> openMapMessageChat(
  BuildContext context, {
  required String messageId,
  GeoMessage? cachedMessage,
  bool isAnonymous = false,
}) async {
  GeoMessage? message = cachedMessage;
  if (message == null || message.id != messageId) {
    try {
      final mapState = context.read<MapBloc>().state;
      for (final entry in mapState.messages) {
        if (entry.id == messageId) {
          message = entry;
          break;
        }
      }
    } catch (_) {}
  }

  message ??= await context.read<GeoMessageRepository>().getMessage(messageId);
  if (!context.mounted || message == null) return;

  context.push(
    '/map-message/${message.id}',
    extra: MapMessageChatLaunchArgs(
      parentMessage: message,
      isAnonymous: isAnonymous,
    ),
  );
}

Future<void> openMapMessageChatFromLog(
  BuildContext context,
  UserLogEvent event,
) async {
  final messageId = event.geoMessageDocumentId;
  if (messageId == null) return;
  await openMapMessageChat(context, messageId: messageId);
}
