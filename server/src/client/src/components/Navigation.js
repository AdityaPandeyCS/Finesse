import React from 'react';
import {AppBar, Tabs, Tab} from '@material-ui/core'
import {NavLink} from 'react-router-dom';

const Navigation = () => {
    return (
        <div>
            <AppBar position="static" style={{backgroundColor: "darkblue"}}>
                <Tabs>
                    <NavLink style={{textDecoration: 'none', color: '#fff'}} to="/admin/"><Tab label="Home"/></NavLink>
                    <NavLink style={{textDecoration: 'none', color: '#fff'}} to="/admin/users"><Tab
                        label="Users"/></NavLink>
                </Tabs>
            </AppBar>
        </div>
    );
}

export default Navigation;
