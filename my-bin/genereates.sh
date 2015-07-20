#!/usr/bin/env bash

rails g migration CreateJoinTableUserYoutube user youtube #TODO Add 't.references :delivery' to migration file
rails g migration CreateJoinTableFestivalUser festival user
rails g migration CreateJoinTableArtistUser artist user
rails g migration CreateJoinTableArtistYoutube artist youtube
rails g model facebook user:references facebook_id:string
rails g scaffold user email:string name:string first_name:string last_name:string gender:string locale:string timezone:integer fetch_cnt:integer interval:integer delivery_time:time is_active:boolean
rails g model youtube videoId:string title:string
rails g model festival name:string title:string
rails g model delivery user:references delivered_at:date
rails g model artist name:string
rails g controller logins
