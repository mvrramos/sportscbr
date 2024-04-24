import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sportscbr/widgets/admin_source_sheet.dart';

class AdminImagesWidget extends FormField<List> {
  AdminImagesWidget(
    BuildContext context, {
    required FormFieldSetter<List> super.onSaved,
    required FormFieldValidator<List> super.validator,
    required List super.initialValue,
    bool autovalidate = false,
    super.key,
  }) : super(
          autovalidateMode: autovalidate ? AutovalidateMode.always : null,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 124,
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: state.value!.map<Widget>((i) {
                      return Container(
                        height: 100,
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onLongPress: () {
                            state.didChange(state.value!..remove(i));
                          },
                          child: i is String
                              ? (i.startsWith('http') || i.startsWith('https'))
                                  ? Image.network(
                                      i,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(i),
                                      fit: BoxFit.cover,
                                    )
                              : Image.file(
                                  File(i),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      );
                    }).toList()
                      ..add(GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => AdminImageSourceSheet((image) {
                              state.didChange(state.value!..add(image.path)); // Adicionando o caminho do arquivo (String)
                              Navigator.of(context).pop();
                            }),
                          );
                        },
                        child: Container(
                          height: 100,
                          width: 100,
                          color: const Color.fromARGB(100, 73, 5, 182),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      )),
                  ),
                ),
                if (state.hasError)
                  Text(
                    "${state.errorText}",
                    style: TextStyle(color: Colors.red[900], fontSize: 12),
                  )
                else
                  Container(),
              ],
            );
          },
        );
}
