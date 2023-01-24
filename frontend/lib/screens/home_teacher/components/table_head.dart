import 'package:flutter/material.dart';
import 'package:journal/constants.dart';

import 'model.dart';
import 'table_cell.dart';

class TableHead extends StatelessWidget {
  final ScrollController scrollController;
  final List<Lab> labs;

  @override
  TableHead({
    @required this.scrollController,
    @required this.labs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cellHeight,
      child: Row(
        children: [
          MultiplicationTableCell(
            color: Colors.yellow.withOpacity(0.3),
          ),
          Expanded(
            child: ListView.builder(
                controller: scrollController,
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: labs.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: cellWidth,
                    height: cellHeight,
                    decoration: BoxDecoration(
                      color: Colors.yellow.withOpacity(0.3),
                      border: Border.all(
                        color: Colors.black12,
                        width: 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      labs[index].lab,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

