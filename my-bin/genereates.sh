#!/usr/bin/env bash

rails g migration CreateJoinTableArtistUser artist user
rails g migration CreateJoinTableArtistYoutube artist youtube
rails g scaffold user email:string locale:string timezone:integer delivery_time:time is_active:boolean
rails g model facebook user:references facebook_user_id:string
rails g model artist name:string
rails g model youtube videoId:string title:string
rails g model delivery date:datetime user:references youtube:references

rails g controller logins
rails g controller lists
