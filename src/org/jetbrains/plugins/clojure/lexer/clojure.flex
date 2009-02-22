/*
 * Copyright 2000-2009 Red Shark Technology
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.jetbrains.plugins.clojure.lexer;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import java.util.*;
import java.io.CharArrayReader;
import org.jetbrains.annotations.NotNull;

%%

%class _ClojureLexer
%implements ClojureTokenTypes, FlexLexer
%unicode
%public

%function advance
%type IElementType

%eof{ return;
%eof}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// User code //////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

%{
  /*
  public final int getTokenStart(){
    return zzStartRead;
  }

  public final int getTokenEnd(){
    return getTokenStart() + yylength();
  }

  public void reset(CharSequence buffer, int start, int end,int initialState) {
    char [] buf = buffer.toString().substring(start,end).toCharArray();
    yyreset( new CharArrayReader( buf ) );
    yybegin(initialState);
  }
  
  public void reset(CharSequence buffer, int initialState){
    reset(buffer, 0, buffer.length(), initialState);
  }
  */
%}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////// NewLines and spaces /////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

mNL = \r | \n | \r\n                                    // NewLines
mWS = " " | \t | \f | {mNL}                       // Whitespaces
mCOMMA = ","

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////// Parens, Squares, Curleys, Quotes /////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

mLP = "("
mRP = ")"
mLS = "["
mRS = "]"
mLC = "{"
mRC = "}"

mQUOTE = "'"
mBACKQUOTE = "`"
mSHARP = "#"
mSHARPUP = {mSHARP} {mUP}
mUP = "^"
mSHARP_CURLY = "#{"
mPERCENT = "%"
mTILDA = "~"
mAT = "@"
mTILDAAT = {mTILDA} {mAT}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////// Strings /////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

mONE_NL = \r | \n | \r\n
mHEX_DIGIT = [0-9A-Fa-f]
mSTRING_ESC = \\ n | \\ r | \\ t | \\ b | \\ f | "\\" "\\" | \\ "$" | \\ \" | \\ \'
    | "\\""u"{mHEX_DIGIT}{4}
    | "\\" [0..3] ([0..7] ([0..7])?)?
    | "\\" [4..7] ([0..7])?
    | "\\" {mONE_NL}

mSTRING_CONTENT = ({mSTRING_ESC}|[^\\\"])*
mSTRING = \"\" | \" ([^\\\"] | {mSTRING_ESC})? {mSTRING_CONTENT} \"
mWRONG_STRING = \" ([^\\\"] | {mSTRING_ESC})? {mSTRING_CONTENT}

mCHAR = \\ [^\r\n]
    | \\ [:jletter:]+

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////// Comments ////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

mLINE_COMMENT = ";" [^\r\n]*

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////      integers and floats     /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

mDIGIT = [0-9]

// Integer
mINTEGER = {mDIGIT}+

//Float
mFLOAT = {mDIGIT}+ "." {mDIGIT}+

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////      identifiers      ////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

mLETTER = [A-Z] | [a-z]
mSLASH_LETTER = \\ ({mLETTER} | .)

mOTHER = "_" | "-" | "*" | "." | "+" | "=" | "&" | "<" | ">" | "$" | "/" | "?" | "!"

mNoDigit = ({mLETTER} | {mOTHER} | {mSLASH_LETTER})
mIDENT = {mNoDigit} ({mNoDigit} | {mDIGIT})* "#"?
mKEY = ":" {mIDENT}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////      predefined      ////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

mNIL = "nil"
mTRUE = "true"
mFALSE = "false"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////  states ///////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

%%
<YYINITIAL>{

  {mLINE_COMMENT}                           {  return LINE_COMMENT; }

  {mWS}+                                    {  return WHITESPACE; }
  {mCOMMA}                                  {  return COMMA; }

  {mCHAR}                                   {  return CHAR_LITERAL; }
  {mNIL}                                    {  return NIL; }
  {mTRUE}                                   {  return TRUE; }
  {mFALSE}                                  {  return FALSE; }

  {mINTEGER}                                {  return INTEGER_LITERAL; }
  {mFLOAT}                                  {  return FLOAT_LITERAL; }
  {mIDENT}                                  {  return SYMBOL; }
  {mKEY}                                    {  return COLON_SYMBOL; }


  {mQUOTE}                                  {  return QUOTE; }
  {mBACKQUOTE}                              {  return BACKQUOTE; }
  {mSHARPUP}                                {  return SHARPUP; }
  {mSHARP_CURLY }                           {  return SHARP_CURLY; }
  {mSHARP}                                  {  return SHARP; }
  {mUP}                                     {  return UP; }
  {mPERCENT}                                {  return PERCENT; }
  {mTILDA}                                  {  return TILDA; }
  {mAT}                                     {  return AT; }
  {mTILDAAT}                                {  return TILDAAT; }


  {mLP}                                     {  return LEFT_PAREN; }
  {mRP}                                     {  return RIGHT_PAREN; }
  {mLS}                                     {  return LEFT_SQUARE; }
  {mRS}                                     {  return RIGHT_SQUARE; }
  {mLC}                                     {  return LEFT_CURLY; }
  {mRC}                                     {  return RIGHT_CURLY; }

  {mSTRING}                                 {  return STRING_LITERAL; }
  {mWRONG_STRING }                          {  return WRONG_STRING_LITERAL; }

}

// Anything else is should be marked as a bad char
.                                           {  return BAD_CHARACTER; }




