import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/core/models/item.dart';
import 'package:flutter_firebase_template/core/models/user.dart';
import 'package:flutter_firebase_template/core/viewmodels/home_model.dart';
import 'package:flutter_firebase_template/core/viewmodels/view_state.dart';
import 'package:flutter_firebase_template/ui/views/base_view.dart';
import 'package:flutter_firebase_template/ui/views/home_view_args.dart';
import 'package:flutter_firebase_template/ui/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  final HomeViewArgs homeViewArgs;

  const HomeView({this.homeViewArgs});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeModel>(
      onModelReady: (model) {
        model.getUserData(Provider.of<User>(context).id);
        model.getItems();

        if (widget.homeViewArgs?.snackbarMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text(widget.homeViewArgs.snackbarMessage),
                action: widget.homeViewArgs.deletedItem != null ? SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    model.undoDeleteItem(widget.homeViewArgs.deletedItem);
                  },
                ) : null,
              ),
            ),
          );
        }
      },
      builder: (context, model, child) => Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Flutter Firebase Template'),
            ),
            drawer: Drawer(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        UserAccountsDrawerHeader(
                          accountName: model.userData != null
                              ? Text(model.userData.username)
                              : Text(''),
                          accountEmail: model.userData != null
                              ? Text(model.userData.email)
                              : Text(''),
                        ),
                        ListTile(
                          title: Text('Item 1'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: <Widget>[
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text('Settings'),
                          onTap: model.navigateToSettingsView,
                        ),
                        ListTile(
                          leading: Icon(Icons.exit_to_app),
                          title: Text('Logout'),
                          onTap: model.logout,
                        ),
                        SizedBox(
                          height: 5.0,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            body: _buildItemList(context, model),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                await model.createRandomItem();
                await model.getItems();
              },
            ),
          ),
          model.state == ViewState.Busy ? LoadingOverlay() : Container(),
        ],
      ),
    );
  }

  Widget _buildItemList(BuildContext context, HomeModel model) {
    return RefreshIndicator(
      onRefresh: model.getItems,
      child: ListView(
        padding: const EdgeInsets.only(top: 5.0),
        children: model.items
            .map((item) => _buildItem(context, model, item))
            .toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, HomeModel model, Item item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        child: ListTile(
          title: Text(item.title + ' (${item.id})'),
          subtitle: Text(
            item.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          onTap: () {
            model.navigateToDetailView(item);
          },
        ),
      ),
    );
  }
}
