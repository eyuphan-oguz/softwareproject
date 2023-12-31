import 'package:flutter/material.dart';
import 'package:softwareproject/product/constant/colors.dart';
import 'package:softwareproject/product/constant/icon.dart';



class TextFormFieldWidget extends StatefulWidget {
  const TextFormFieldWidget({super.key, required this.hintText, required this.size, required this.icon, required this.isPasswordField, required this.controller, required this.type, required this.visible, this.autoFillHints, this.maxLines});
  final String hintText;
  final Size size;
  final IconData icon;
  final bool isPasswordField;
  final TextEditingController controller;
  final TextInputType type;
  final bool visible;
  final Iterable<String>? autoFillHints;
  final int? maxLines;
  @override
  State<TextFormFieldWidget> createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {

  late bool _obscureText = widget.visible;
  Icon showPasswordIcon=Icon(ProjectIcon().passwordIconVisibleOff);

  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }



  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }


  @override
  Widget build(BuildContext context) {
    return _textFormFieldDesign(child:_textFormFieldWidget());
  }







  TextFormField _textFormFieldWidget() {
    return TextFormField(
          style: TextStyle(fontSize: 15,color:Colors.white),
          autofillHints: widget.autoFillHints,
          key: _formKey,
          focusNode: _focusNode,
          keyboardType: widget.type,
          controller: widget.controller,
          obscureText: _obscureText,
          textAlignVertical:
          widget.isPasswordField ? TextAlignVertical.center : null,
          decoration: _textFormFieldDecoration(),
          minLines: 1,
        );
  }

  InputDecoration _textFormFieldDecoration() {
    return InputDecoration(
           
            suffixIcon: widget.isPasswordField
                ? InkWell(
                onTap: () {
                  _toggle();
                },
                child: _changeIconForPassword(_obscureText))
                : null,
            enabledBorder:textFormFieldInputBorder(),
            focusedBorder: textFormFieldInputBorder(),
            contentPadding:
            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: ProjectColor().textFormFieldHintTextColor));
  }


  Widget _changeIconForPassword(bool obscureText){
    setState(() {
      if(obscureText ==true){
      showPasswordIcon=Icon(ProjectIcon().passwordIconVisibleOff,color:focusedChangeColorIcon(_isFocused) ,);
    }else{
      showPasswordIcon=Icon(ProjectIcon().passwordIconVisibleOn,color: focusedChangeColorIcon(_isFocused),);
    }
    });
    return (showPasswordIcon);
  }

  Widget _textFormFieldDesign({ required Widget child}){
    return Material(
      elevation: 5.0,
      child: Container(alignment: Alignment.center,
      height:widget.maxLines==null ? widget.size.height*0.06 : null,
      
      decoration: BoxDecoration(
      color: ProjectColor().textFormFieldBackgroundColor,),
      child: Center(child: child),
      ),
      
    );
  }

  focusedChangeColorIcon(bool isFocused){
    return isFocused ? ProjectColor().selectedTextFormFieldColor : ProjectColor().notSelectedTextFormFieldColor;
  }

  InputBorder textFormFieldInputBorder(){
    return const OutlineInputBorder(
              borderSide: BorderSide.none,
            );
  }

}
