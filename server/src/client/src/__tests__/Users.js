import React from 'react';
import renderer from 'react-test-renderer';
import Users from '../components/Users';
import axios from 'axios';
import mockAdaptor from 'axios-mock-adapter';
import { shallow } from 'enzyme';

describe("Password reset page", () => {
    it('It should load password reset page with invalid token message', () => {
        const component = renderer.create(
            <Users/>
        );
        let tree = component.toJSON();
        expect(tree).toMatchSnapshot();
    });

    // it('It should expect to call post for checkEmailTokenExists', () => {
    //     const spy = jest.spyOn(Users.prototype, 'componentDidMount');
    //     const users = shallow(<Users/>);
    //
    //     const mockData = {msg: "Found valid email/token"};
    //
    //     const mock = new mockAdapter(axios);
    //     mock.onPost("api/user/checkEmailTokenExists")
    //         .reply(200, mockData);
    //
    //     users.find('');
    //
    //     expect(spy).toHaveBeenCalled();
    // });
});

